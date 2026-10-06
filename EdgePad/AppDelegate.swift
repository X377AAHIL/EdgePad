import Cocoa
import SwiftUI
import os.log

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let recognizer = EdgeGestureRecognizer()
    private var tap: GestureEventTap?
    private var appProfiles: AppProfilesConfiguration = .default

    private var heartbeatTimer: Timer?
    private let log = Logger(subsystem: "com.aahilshaaravg.EdgePad", category: "Background")
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var popoverMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        

        appProfiles = ConfigurationStore.shared.load()
        updateActiveProfile()
        recognizer.onStep = { [weak self] edge, direction in
            self?.perform(edge: edge, direction: direction)
        }

        if PermissionChecker.hasAccessibility {
            startTap()
        } else {
            PermissionChecker.requestAccessibility()
            PermissionChecker.waitForAccessibility { [weak self] in
                self?.startTap()
            }
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.log.info("System woke from sleep – restarting event tap")
                self?.restartTapIfNeeded()
            }
        }

        // Screen lock/unlock can also silently break the event tap
        DistributedNotificationCenter.default().addObserver(
            forName: .init("com.apple.screenIsLocked"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.log.info("Screen locked")
            }
        }

        DistributedNotificationCenter.default().addObserver(
            forName: .init("com.apple.screenIsUnlocked"),
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.log.info("Screen unlocked – restarting event tap")
                self?.restartTapIfNeeded()
            }
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateActiveProfile()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .edgeConfigurationChanged,
            object: nil, queue: .main
        ) { [weak self] notification in
            guard let profiles = notification.object as? AppProfilesConfiguration else { return }
            Task { @MainActor [weak self, profiles] in
                self?.appProfiles = profiles
                self?.updateActiveProfile()
            }
        }

        // Heartbeat: periodically verify the event tap is still alive.
        // macOS can silently disable taps after long idle periods.
        startHeartbeat()
    }

    private func updateActiveProfile() {
        let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        let config = appProfiles.appProfiles[bundleID] ?? appProfiles.defaultProfile
        recognizer.configuration = config
    }

    func applicationWillTerminate(_ notification: Notification) {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        tap?.stop()
    }

    private func startTap() {
        let tap = GestureEventTap { [weak self] event, type in
            self?.handle(event: event, type: type) ?? false
        }
        if tap.start() {
            self.tap = tap
        } else {
            presentPermissionAlert()
        }
    }

    private func restartTapIfNeeded() {
        guard PermissionChecker.hasAccessibility else { return }
        tap?.stop()
        tap = nil
        recognizer.reset()
        startTap()
    }

    // MARK: - Heartbeat

    /// Periodically checks that the event tap is still enabled.
    /// If macOS silently disabled it (e.g. tapDisabledByTimeout that
    /// the CGEvent callback didn't catch), we restart it.
    private func startHeartbeat() {
        let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.verifyTapAlive()
            }
        }
        timer.tolerance = 5
        heartbeatTimer = timer
    }

    private func verifyTapAlive() {
        guard let tap else {
            // No tap at all – maybe permissions weren't granted yet
            if PermissionChecker.hasAccessibility {
                log.warning("Event tap was nil – attempting restart")
                startTap()
            }
            return
        }
        if !tap.isEnabled {
            log.warning("Event tap was disabled by system – restarting")
            restartTapIfNeeded()
        }
    }

    private func handle(event: NSEvent, type: CGEventType) -> Bool {
        if type == .scrollWheel {
            return recognizer.hasActiveGesture // Swallow the scroll event if active
        }

        if type == .mouseMoved || type == .leftMouseDragged || type == .rightMouseDragged || type == .otherMouseDragged {
            if recognizer.hasActiveGesture {
                if let loc = recognizer.lockedCursorLocation {
                    CGWarpMouseCursorPosition(loc)
                }
                return true
            }
            return false
        }

        let touches = event.allTouches()
        guard !touches.isEmpty else {
            return false
        }
        recognizer.process(touches: touches)
        tap?.isGestureActive = recognizer.hasActiveGesture
        return false
    }

    private func perform(edge: TrackpadEdge, direction: Int) {
        guard let binding = recognizer.configuration.bindings[edge] else { return }
        switch binding.action {
        case .none: break
        case .volume: 
            SystemVolume.nudge(direction)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        case .brightness: 
            SystemBrightness.nudge(direction)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        case .keyboardBacklight: 
            KeyboardBacklight.nudge(direction)
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
        case .scroll: postScroll(direction)
        case .mediaScrub: postArrowKey(direction, fast: false)
        case .mediaScrubFast: postArrowKey(direction, fast: true)
        }
    }

    private func postArrowKey(_ direction: Int, fast: Bool) {
        let keyCode: CGKeyCode = direction > 0 ? 124 : 123 // 124: Right, 123: Left
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        
        if fast {
            keyDown?.flags = .maskAlternate
            keyUp?.flags = .maskAlternate
        }
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func postScroll(_ direction: Int) {
        guard let event = CGEvent(
            scrollWheelEvent2Source: nil,
            units: .line,
            wheelCount: 1,
            wheel1: Int32(direction * 3),
            wheel2: 0, wheel3: 0
        ) else { return }
        event.post(tap: .cghidEventTap)
    }

    private func presentPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "EdgePad needs permission"
        alert.informativeText = """
EdgePad reads trackpad touches, which macOS treats as privileged input.

Enable EdgePad under Privacy & Security → Accessibility. If gestures \
still do not register, also add it under Input Monitoring.
"""
        alert.addButton(withTitle: "Open Accessibility")
        alert.addButton(withTitle: "Open Input Monitoring")
        alert.addButton(withTitle: "Later")

        switch alert.runModal() {
        case .alertFirstButtonReturn: PermissionChecker.openAccessibilitySettings()
        case .alertSecondButtonReturn: PermissionChecker.openInputMonitoringSettings()
        default: break
        }
    }
    
    // MARK: - Menu Bar & Popover Lifecycle
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if let popover = popover, popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    private func showPopover(_ sender: AnyObject?) {
        if popover == nil {
            popover = NSPopover()
            popover?.behavior = .transient
            popover?.delegate = self
        }
        
        // Re-instantiate the view every time to save memory when closed
        let hostingController = NSHostingController(rootView: PreferencesView())
        popover?.contentViewController = hostingController

        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func closePopover(_ sender: AnyObject?) {
        popover?.performClose(sender)
        // Note: The actual memory teardown happens in popoverDidClose delegate method
        // which gets called whether closed manually or by clicking outside (.transient)
    }
}

extension AppDelegate: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        // We MUST asynchronously tear down the view hierarchy.
        // Niling out the popover synchronously during its own `popoverDidClose`
        // callback interrupts its internal teardown process, causing the invisible 
        // SwiftUI window to leak and burn CPU infinitely in the background.
        let popoverToRelease = popover
        popover = nil
        
        DispatchQueue.main.async {
            popoverToRelease?.contentViewController = nil
        }
    }
}
