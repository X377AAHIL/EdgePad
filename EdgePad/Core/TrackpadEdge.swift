import Foundation

enum TrackpadEdge: String, CaseIterable, Codable, Identifiable, Sendable {
    case left, right, top, bottom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .left:
            return "Left edge"
        case .right:
            return "Right edge"
        case .top:
            return "Top edge"
        case .bottom:
            return "Bottom edge"
        }
    }

    var travelIsVertical: Bool {
        self == .left || self == .right
    }

    func travelValue(of point: CGPoint) -> CGFloat {
        travelIsVertical ? point.y : point.x
    }

    func depth(of point: CGPoint) -> CGFloat {
        switch self {
        case .left:
            return point.x
        case .right:
            return 1 - point.x
        case .bottom:
            return point.y
        case .top:
            return 1 - point.y
        }
    }
}
