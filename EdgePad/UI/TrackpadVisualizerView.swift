import SwiftUI

struct TrackpadVisualizerView: View {
    let configuration: EdgeConfiguration
    let selectedEdge: TrackpadEdge?

    // Compact dimensions that fit within the 320px popover
    private let trackpadWidth: CGFloat = 200
    private let trackpadHeight: CGFloat = 130
    private let cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            // 1. Trackpad chassis — dark rounded rect with subtle border
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .frame(width: trackpadWidth, height: trackpadHeight)

            // 2. Edge hitboxes — drawn INSIDE the chassis and clipped to it
            Canvas { context, size in
                let rect = CGRect(
                    x: (size.width - trackpadWidth) / 2,
                    y: (size.height - trackpadHeight) / 2,
                    width: trackpadWidth,
                    height: trackpadHeight
                )
                let clipPath = Path(roundedRect: rect, cornerRadius: cornerRadius, style: .continuous)

                // Draw each edge hitbox
                for edge in TrackpadEdge.allCases {
                    let isSelected = edge == selectedEdge
                    let binding = configuration.bindings[edge]
                    let thickness = binding?.bandThickness ?? 0.1

                    let edgeRect: CGRect = {
                        switch edge {
                        case .top:
                            return CGRect(x: rect.minX, y: rect.minY,
                                          width: rect.width, height: rect.height * thickness)
                        case .bottom:
                            let h = rect.height * thickness
                            return CGRect(x: rect.minX, y: rect.maxY - h,
                                          width: rect.width, height: h)
                        case .left:
                            return CGRect(x: rect.minX, y: rect.minY,
                                          width: rect.width * thickness, height: rect.height)
                        case .right:
                            let w = rect.width * thickness
                            return CGRect(x: rect.maxX - w, y: rect.minY,
                                          width: w, height: rect.height)
                        }
                    }()

                    // Clip to the rounded trackpad shape
                    context.clipToLayer { ctx in
                        ctx.fill(clipPath, with: .color(.white))
                    }

                    let color: Color = isSelected
                        ? GlassColors.accentCyan.opacity(0.45)
                        : Color.white.opacity(0.04)

                    context.fill(Path(edgeRect), with: .color(color))

                    // Reset clip for next iteration
                    context.clip(to: Path(CGRect(origin: .zero, size: size)))
                }
            }
            .frame(width: trackpadWidth + 20, height: trackpadHeight + 20)
            .allowsHitTesting(false)

            // 3. Selected edge glow border (drawn on top for polish)
            if let edge = selectedEdge {
                selectedEdgeGlow(edge)
            }
        }
        .frame(height: trackpadHeight + 24)
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.25), value: selectedEdge)
        .animation(.easeInOut(duration: 0.25), value: configuration.bindings[selectedEdge ?? .top]?.bandThickness)
    }

    /// A thin glowing line on the selected edge of the trackpad
    @ViewBuilder
    private func selectedEdgeGlow(_ edge: TrackpadEdge) -> some View {
        let glowThickness: CGFloat = 2

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(Color.clear, lineWidth: 0) // placeholder for alignment
            .frame(width: trackpadWidth, height: trackpadHeight)
            .overlay(alignment: edgeAlignment(edge)) {
                Capsule()
                    .fill(GlassColors.accentCyan.opacity(0.8))
                    .shadow(color: GlassColors.accentCyan.opacity(0.6), radius: 8)
                    .frame(
                        width: edge == .left || edge == .right ? glowThickness : trackpadWidth * 0.6,
                        height: edge == .top || edge == .bottom ? glowThickness : trackpadHeight * 0.6
                    )
                    .padding(4)
            }
    }

    private func edgeAlignment(_ edge: TrackpadEdge) -> Alignment {
        switch edge {
        case .top: return .top
        case .bottom: return .bottom
        case .left: return .leading
        case .right: return .trailing
        }
    }
}
