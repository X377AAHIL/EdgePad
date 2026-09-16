import Foundation

enum EdgeAction: String, Codable, CaseIterable, Identifiable, Sendable {
    case none
    case volume
    case brightness
    case keyboardBacklight
    case scroll
    case mediaScrub

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:
            return "Nothing"
        case .volume:
            return "Volume"
        case .brightness:
            return "Display brightness"
        case .keyboardBacklight:
            return "Keyboard backlight"
        case .scroll:
            return "Scroll"
        case .mediaScrub:
            return "Track skip"
        }
    }
}

struct EdgeBinding: Codable, Equatable, Sendable {
    var action: EdgeAction = .none
    var bandThickness: CGFloat = 0.08
    var stepDistance: CGFloat = 0.05
    var escapeMargin: CGFloat = 0.08
    var inverted: Bool = false
    var minimumDwell: TimeInterval = 0.08
    var requiredTouchCount: Int = 1

    var isEnabled: Bool { action != .none }
}

struct EdgeConfiguration: Codable, Equatable, Sendable {
    var bindings: [TrackpadEdge: EdgeBinding]

    static let `default` = EdgeConfiguration(bindings: [
        .right: EdgeBinding(action: .volume, requiredTouchCount: 2),
        .top: EdgeBinding(action: .brightness, requiredTouchCount: 1),
        .left: EdgeBinding(action: .none, requiredTouchCount: 2),
        .bottom: EdgeBinding(action: .none, requiredTouchCount: 1),
    ])
}
