import Foundation

enum EdgeAction: String, Codable, CaseIterable, Identifiable, Sendable {
    case none, volume, brightness, keyboardBacklight, scroll, mediaScrub, mediaScrubFast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .volume:
            return "Volume"
        case .brightness:
            return "Brightness"
        case .keyboardBacklight:
            return "Keyboard backlight"
        case .scroll:
            return "Scroll"
        case .mediaScrub:
            return "Media scrub"
        case .mediaScrubFast:
            return "Media scrub (Fast)"
        }
    }
}

struct EdgeBinding: Codable, Equatable, Sendable {
    var action: EdgeAction = .none
    var bandThickness: CGFloat = 0.12
    var stepDistance: CGFloat = 0.05
    var escapeMargin: CGFloat = 0.08
    var inverted: Bool = false
    var minimumDwell: TimeInterval = 0.08
    var requiredTouchCount: Int = 1

    var isEnabled: Bool { action != .none }
}

struct EdgeConfiguration: Codable, Equatable, Sendable {
    var bindings: [TrackpadEdge: EdgeBinding]
}

struct AppProfilesConfiguration: Codable, Equatable, Sendable {
    var defaultProfile: EdgeConfiguration
    var appProfiles: [String: EdgeConfiguration]

    static let `default` = AppProfilesConfiguration(
        defaultProfile: EdgeConfiguration(bindings: [
            .right: EdgeBinding(action: .volume, bandThickness: 0.12, stepDistance: 0.0625, requiredTouchCount: 2),
            .top: EdgeBinding(action: .brightness, stepDistance: 0.15, requiredTouchCount: 1),
            .left: EdgeBinding(action: .none, requiredTouchCount: 2),
            .bottom: EdgeBinding(action: .mediaScrub, stepDistance: 0.05, requiredTouchCount: 1),
        ]),
        appProfiles: [
            "com.apple.QuickTimePlayerX": EdgeConfiguration(bindings: [
                .right: EdgeBinding(action: .volume, requiredTouchCount: 2),
                .top: EdgeBinding(action: .brightness, requiredTouchCount: 1),
                .left: EdgeBinding(action: .none, requiredTouchCount: 2),
                .bottom: EdgeBinding(action: .mediaScrub, stepDistance: 0.015, requiredTouchCount: 1),
            ])
        ]
    )
}
