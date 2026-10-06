import Cocoa

final class GestureEventTap: @unchecked Sendable {

    typealias Handler = (NSEvent, CGEventType) -> Bool
    private static let gestureRawValue: UInt32 = 29

    /// Set by the owner to indicate whether an edge gesture is in progress.
    /// When `false`, the secondary mouse/scroll event tap is completely disabled
    /// at the OS level, meaning macOS will not wake up this process for the thousands
    /// of mouse movements that occur every second. This drops idle energy impact to 0%.
    var isGestureActive = false {
        didSet {
            guard isGestureActive != oldValue, let port = mousePort else { return }
            CGEvent.tapEnable(tap: port, enable: isGestureActive)
        }
    }

    private var touchPort: CFMachPort?
    private var touchSource: CFRunLoopSource?
    
    private var mousePort: CFMachPort?
    private var mouseSource: CFRunLoopSource?
    
    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    /// Whether the primary underlying CGEvent tap is currently enabled.
    var isEnabled: Bool {
        guard let port = touchPort else { return false }
        return CGEvent.tapIsEnabled(tap: port)
    }

    @discardableResult
    func start() -> Bool {
        guard touchPort == nil else { return true }

        let touchMask: CGEventMask = (1 << UInt64(Self.gestureRawValue))
        let mouseMask: CGEventMask =
            (1 << UInt64(CGEventType.scrollWheel.rawValue))
            | (1 << UInt64(CGEventType.mouseMoved.rawValue))
            | (1 << UInt64(CGEventType.leftMouseDragged.rawValue))
            | (1 << UInt64(CGEventType.rightMouseDragged.rawValue))
            | (1 << UInt64(CGEventType.otherMouseDragged.rawValue))

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let tap = Unmanaged<GestureEventTap>.fromOpaque(refcon).takeUnretainedValue()
            return tap.process(type: type, event: event)
        }

        let refcon = Unmanaged.passUnretained(self).toOpaque()

        guard let tPort = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: touchMask, callback: callback, userInfo: refcon
        ), let mPort = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: mouseMask, callback: callback, userInfo: refcon
        ) else { return false }

        touchPort = tPort
        touchSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tPort, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), touchSource, .commonModes)
        CGEvent.tapEnable(tap: tPort, enable: true)
        
        mousePort = mPort
        mouseSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mPort, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), mouseSource, .commonModes)
        // Ensure the mouse port starts completely disabled so it uses zero CPU.
        CGEvent.tapEnable(tap: mPort, enable: false)

        return true
    }

    func stop() {
        if let tSource = touchSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), tSource, .commonModes) }
        if let mSource = mouseSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), mSource, .commonModes) }
        
        if let tPort = touchPort {
            CGEvent.tapEnable(tap: tPort, enable: false)
            CFMachPortInvalidate(tPort)
        }
        if let mPort = mousePort {
            CGEvent.tapEnable(tap: mPort, enable: false)
            CFMachPortInvalidate(mPort)
        }
        
        touchSource = nil; mouseSource = nil
        touchPort = nil; mousePort = nil
    }

    private func process(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tPort = touchPort { CGEvent.tapEnable(tap: tPort, enable: true) }
            if let mPort = mousePort, isGestureActive { CGEvent.tapEnable(tap: mPort, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        // If we receive a mouse/scroll event when !isGestureActive, it's a race condition
        // (the event was in-flight while we disabled the port). Safely pass it through.
        if !isGestureActive && type != CGEventType(rawValue: Self.gestureRawValue) {
            return Unmanaged.passUnretained(event)
        }

        guard let nsEvent = NSEvent(cgEvent: event) else {
            return Unmanaged.passUnretained(event)
        }

        return handler(nsEvent, type) ? nil : Unmanaged.passUnretained(event)
    }
}