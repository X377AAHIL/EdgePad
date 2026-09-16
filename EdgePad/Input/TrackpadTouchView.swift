import Cocoa

final class TrackpadTouchView: NSView {

    var onTouches: ((Set<NSTouch>) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        allowedTouchTypes = [.indirect]
        wantsRestingTouches = false
    }

    override var acceptsFirstResponder: Bool { true }

    override func touchesBegan(with event: NSEvent) { report(event) }
    override func touchesMoved(with event: NSEvent) { report(event) }
    override func touchesEnded(with event: NSEvent) { report(event) }
    override func touchesCancelled(with event: NSEvent) { report(event) }

    private func report(_ event: NSEvent) {
        onTouches?(event.touches(matching: .any, in: self))
    }
}