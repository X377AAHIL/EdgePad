import AppKit

@MainActor
final class EdgeGestureRecognizer {

    var configuration: EdgeConfiguration = AppProfilesConfiguration.default.defaultProfile

    var onStep: ((TrackpadEdge, Int) -> Void)?

    private(set) var hasActiveGesture = false {
        didSet {
            if hasActiveGesture && !oldValue {
                lockedCursorLocation = CGEvent(source: nil)?.location
                startRepeatTimer()
            } else if !hasActiveGesture && oldValue {
                lockedCursorLocation = nil
                stopRepeatTimer()
            }
        }
    }

    private(set) var lockedCursorLocation: CGPoint?
    private var repeatTimer: Timer?

    private struct Track {
        let edge: TrackpadEdge
        var initialTravel: CGFloat
        var currentTravel: CGFloat
        var lastTravel: CGFloat
        var accumulated: CGFloat = 0
        var startTime: Date
        var hasFired: Bool = false
    }

    private var tracks: [ObjectIdentifier: Track] = [:]

    private func startRepeatTimer() {
        repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleRepeat()
            }
        }
    }

    private func stopRepeatTimer() {
        repeatTimer?.invalidate()
        repeatTimer = nil
    }

    private func handleRepeat() {
        for (key, var track) in tracks {
            guard let binding = configuration.bindings[track.edge], binding.isEnabled else { continue }
            guard track.hasFired else { continue }

            let activeTracksOnEdge = tracks.values.filter { $0.edge == track.edge }.count
            guard activeTracksOnEdge >= binding.requiredTouchCount else { continue }

            let displacement = track.currentTravel - track.initialTravel
            let deadzone: CGFloat = 0.05

            if abs(displacement) > deadzone {
                let activeDisplacement = displacement > 0 ? displacement - deadzone : displacement + deadzone
                // Adjust this multiplier to tune the continuous scroll speed
                let speedMultiplier: CGFloat = 2.5
                let stepAmount = activeDisplacement * speedMultiplier * binding.stepDistance
                
                track.accumulated += stepAmount

                while abs(track.accumulated) >= binding.stepDistance {
                    let raw = track.accumulated > 0 ? 1 : -1
                    onStep?(track.edge, binding.inverted ? -raw : raw)
                    track.accumulated -= CGFloat(raw) * binding.stepDistance
                }
                
                tracks[key] = track
            }
        }
    }

    func process(touches: Set<NSTouch>) {
        let activeTouchesCount = touches.filter { 
            $0.type == .indirect && !$0.isResting && $0.phase != .ended && $0.phase != .cancelled 
        }.count
        
        // If no fingers are actively on the trackpad, kill all ongoing processes immediately
        if activeTouchesCount == 0 {
            reset()
            return
        }

        // Strictly ignore gestures with more than 2 fingers
        if activeTouchesCount > 2 {
            reset()
            return
        }

        for touch in touches {
            guard touch.type == .indirect else { continue }

            let key = ObjectIdentifier(touch.identity as AnyObject)
            if touch.isResting {
                tracks[key] = nil
                continue
            }

            handle(touch)
        }
        hasActiveGesture = !tracks.isEmpty
    }

    func reset() {
        tracks.removeAll()
        hasActiveGesture = false
    }

    private func handle(_ touch: NSTouch) {
        let key = ObjectIdentifier(touch.identity as AnyObject)
        let position = touch.normalizedPosition

        switch touch.phase {
        case .began:
            guard let edge = edge(containing: position),
                  let binding = configuration.bindings[edge],
                  binding.isEnabled
            else { return }
            let travel = edge.travelValue(of: position)
            tracks[key] = Track(
                edge: edge,
                initialTravel: travel,
                currentTravel: travel,
                lastTravel: travel,
                startTime: Date()
            )

        case .moved, .stationary:
            guard var track = tracks[key],
                  let binding = configuration.bindings[track.edge],
                  binding.isEnabled
            else { return }

            if track.edge.depth(of: position) > binding.bandThickness + binding.escapeMargin {
                tracks[key] = nil
                return
            }

            let travel = track.edge.travelValue(of: position)
            track.currentTravel = travel

            if !track.hasFired {
                let dwell = Date().timeIntervalSince(track.startTime)
                if dwell < binding.minimumDwell {
                    // Do not convert travel made before the dwell threshold into a
                    // delayed step once the gesture becomes active.
                    track.lastTravel = travel
                    tracks[key] = track
                    return
                }
                track.hasFired = true
            }

            let activeTracksOnEdge = tracks.values.filter { $0.edge == track.edge }.count
            if activeTracksOnEdge < binding.requiredTouchCount {
                // Discard travel made before the required fingers arrive.
                track.lastTravel = travel
                track.initialTravel = travel // Prevent stored displacement jumps
                tracks[key] = track
                return
            }

            track.accumulated += travel - track.lastTravel
            track.lastTravel = travel

            while abs(track.accumulated) >= binding.stepDistance {
                let raw = track.accumulated > 0 ? 1 : -1
                onStep?(track.edge, binding.inverted ? -raw : raw)
                track.accumulated -= CGFloat(raw) * binding.stepDistance
            }

            tracks[key] = track

        case .ended, .cancelled:
            tracks[key] = nil

        default:
            break
        }
    }

    private func edge(containing p: CGPoint) -> TrackpadEdge? {
        var best: (edge: TrackpadEdge, depth: CGFloat)?

        for edge in TrackpadEdge.allCases {
            guard let binding = configuration.bindings[edge],
                  binding.isEnabled
            else { continue }
            let d = edge.depth(of: p)
            guard d <= binding.bandThickness else { continue }
            if best == nil || d < best!.depth {
                best = (edge, d)
            }
        }
        return best?.edge
    }
}
