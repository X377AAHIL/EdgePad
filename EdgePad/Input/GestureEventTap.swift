import Cocoa

final class GestureEventTap: @unchecked Sendable {

    typealias Handler = (NSEvent, CGEventType) -> Bool

    private static let gestureRawValue: UInt32 = 29

    private var machPort: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    @discardableResult
    func start() -> Bool {
        guard machPort == nil else { return true }

        let mask: CGEventMask =
            (1 << UInt64(Self.gestureRawValue))
            | (1 << UInt64(CGEventType.mouseMoved.rawValue))
            | (1 << UInt64(CGEventType.leftMouseDragged.rawValue))
            | (1 << UInt64(CGEventType.rightMouseDragged.rawValue))
            | (1 << UInt64(CGEventType.otherMouseDragged.rawValue))

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let tap = Unmanaged<GestureEventTap>.fromOpaque(refcon).takeUnretainedValue()
            return tap.process(type: type, event: event)
        }

        guard let port = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        machPort = port
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
        return true
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        if let port = machPort {
            CGEvent.tapEnable(tap: port, enable: false)
            CFMachPortInvalidate(port)
        }
        runLoopSource = nil
        machPort = nil
    }

    private func process(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let port = machPort { CGEvent.tapEnable(tap: port, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        guard let nsEvent = NSEvent(cgEvent: event) else {
            return Unmanaged.passUnretained(event)
        }

        return handler(nsEvent, type) ? nil : Unmanaged.passUnretained(event)
    }
}