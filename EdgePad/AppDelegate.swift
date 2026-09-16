import Cocoa
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let recognizer = EdgeGestureRecognizer()
    private var tap: GestureEventTap?

    func applicationDidFinishLaunching(_ notification: Notification) {
        recognizer.configuration = ConfigurationStore.shared.load()
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
                self?.restartTapIfNeeded()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .edgeConfigurationChanged,
            object: nil, queue: .main
        ) { [weak self] notification in
            guard let config = notification.object as? EdgeConfiguration else { return }
            Task { @MainActor [weak self, config] in
                self?.recognizer.configuration = config
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
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

    private func handle(event: NSEvent, type: CGEventType) -> Bool {
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
        guard !touches.isEmpty else { return false }
        recognizer.process(touches: touches)
        return false
    }

    private func perform(edge: TrackpadEdge, direction: Int) {
        guard let binding = recognizer.configuration.bindings[edge] else { return }
        switch binding.action {
        case .none: break
        case .volume: SystemVolume.nudge(direction)
        case .brightness: SystemBrightness.nudge(direction)
        case .keyboardBacklight: KeyboardBacklight.nudge(direction)
        case .scroll: postScroll(direction)
        case .mediaScrub: HIDKeyPoster.post(direction > 0 ? .next : .previous)
        }
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
