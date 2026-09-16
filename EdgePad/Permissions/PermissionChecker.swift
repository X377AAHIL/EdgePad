import Cocoa
@preconcurrency import ApplicationServices

@MainActor
enum PermissionChecker {
    static var hasAccessibility: Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    static func requestAccessibility() -> Bool {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    static func openInputMonitoringSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        NSWorkspace.shared.open(url)
    }

    static func waitForAccessibility(interval: TimeInterval = 1.0, onGranted: @escaping () -> Void) {
        AccessibilityWaiter.current?.cancel()

        let waiter = AccessibilityWaiter(interval: interval, onGranted: onGranted)
        AccessibilityWaiter.current = waiter
        waiter.start()
    }
}

@MainActor
private final class AccessibilityWaiter: NSObject {
    static var current: AccessibilityWaiter?

    private let interval: TimeInterval
    private let onGranted: () -> Void
    private var timer: Timer?

    init(interval: TimeInterval, onGranted: @escaping () -> Void) {
        self.interval = interval
        self.onGranted = onGranted
    }

    func start() {
        guard !PermissionChecker.hasAccessibility else {
            finish()
            return
        }

        let timer = Timer(
            timeInterval: interval,
            target: self,
            selector: #selector(checkAccessibility),
            userInfo: nil,
            repeats: true
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func checkAccessibility() {
        guard PermissionChecker.hasAccessibility else { return }
        finish()
    }

    private func finish() {
        cancel()
        if Self.current === self {
            Self.current = nil
        }
        onGranted()
    }
}
