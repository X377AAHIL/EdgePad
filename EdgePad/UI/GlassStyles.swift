import SwiftUI

// MARK: - Color Palette (only actively used colors)

enum GlassColors {
    static let accentCyan = Color(red: 0.0, green: 0.8, blue: 0.95)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.6)
}

// MARK: - Animation Presets (only actively used)

enum GlassAnimation {
    static let hoverScale = Animation.easeOut(duration: 0.2)
    static let crossFade = Animation.easeInOut(duration: 0.3)
}

// MARK: - Liquid Glass Fallback

extension View {
    @ViewBuilder
    func glassEffectWithFallback(
        tint: Color = .clear,
        isInteractive: Bool = false,
        fallbackMaterial: Material = .ultraThinMaterial,
        fallbackOpacity: Double = 0.5
    ) -> some View {
        if #available(macOS 26, *) {
            if isInteractive {
                self.glassEffect(.regular.tint(tint).interactive())
            } else {
                self.glassEffect(.regular.tint(tint))
            }
        } else {
            self.background(fallbackMaterial)
                .background(tint.opacity(fallbackOpacity))
        }
    }
}

// MARK: - SF Symbol Mapping

extension EdgeAction {
    var systemImage: String {
        switch self {
        case .none: return "xmark.circle"
        case .volume: return "speaker.wave.2.fill"
        case .brightness: return "sun.max.fill"
        case .keyboardBacklight: return "light.max"
        case .scroll: return "arrow.up.arrow.down"
        case .mediaScrub: return "forward.fill"
        case .mediaScrubFast: return "forward.end.fill"
        }
    }
}
