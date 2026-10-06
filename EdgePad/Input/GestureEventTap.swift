import Cocoa

final class GestureEventTap: @unchecked Sendable {

    typealias Handler = (NSEvent, CGEventType) -> Bool

    private static let gestureRawValue: UInt32 = 29

    /// Set by the owner to indicate whether an edge gesture is in progress.
    /// When `false`, mouse-move/drag/scroll events are short-circuited at
    /// the CGEvent level, avoiding the cost of NSEvent bridging.
    var isGestureActive = false

    private var machPort: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    /// Whether the underlying CGEvent tap is currently enabled.
    /// macOS can disable taps via `tapDisabledByTimeout` or `tapDisabledByUserInput`.
    var isEnabled: Bool {
        guard let port = machPort else { return false }
        return CGEvent.tapIsEnabled(tap: port)
    }


    @discardableResult
    func start() -> Bool {
        guard machPort == nil else { return true }

        let mask: CGEventMask =
            (1 << UInt64(Self.gestureRawValue))
            | (1 << UInt64(CGEventType.scrollWheel.rawValue))
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

        // Short-circuit mouse-move/drag/scroll events when no gesture is active.
        // This avoids the cost of NSEvent bridging for events EdgePad will just
        // pass through, eliminating hundreds of unnecessary wakeups per second.
        if !isGestureActive {
            switch type {
            case .mouseMoved, .leftMouseDragged, .rightMouseDragged,
                 .otherMouseDragged, .scrollWheel:
                return Unmanaged.passUnretained(event)
            default:
                break
            }
        }

        guard let nsEvent = NSEvent(cgEvent: event) else {
            return Unmanaged.passUnretained(event)
        }

        return handler(nsEvent, type) ? nil : Unmanaged.passUnretained(event)
    }
}