import Cocoa
import SwiftUI
import os.log

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let recognizer = EdgeGestureRecognizer()
    private var tap: GestureEventTap?
    private var appProfiles: AppProfilesConfiguration = .default
    private var activityToken: NSObjectProtocol?
    private var heartbeatTimer: Timer?
    private let log = Logger(subsystem: "com.aahilshaaravg.EdgePad", category: "Background")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Use .userInitiatedAllowingIdleSystemSleep to prevent App Nap from
        // suspending the process while still allowing the display to sleep.
        // This is critical for a menu-bar utility that must monitor trackpad
        // events indefinitely.
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiatedAllowingIdleSystemSleep, .latencyCritical],
            reason: "EdgePad must remain active to monitor trackpad edge gestures"
        )
        
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
        if let token = activityToken {
            ProcessInfo.processInfo.endActivity(token)
        }
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
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.verifyTapAlive()
            }
        }
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
}
