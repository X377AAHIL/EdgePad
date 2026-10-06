import SwiftUI

struct TrackpadVisualizerView: View {
    let configuration: EdgeConfiguration
    @Binding var selectedEdge: TrackpadEdge?

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

            // 2. Edge hitboxes with smooth color fading & interaction
            GeometryReader { geo in
                let rect = CGRect(
                    x: (geo.size.width - trackpadWidth) / 2,
                    y: (geo.size.height - trackpadHeight) / 2,
                    width: trackpadWidth,
                    height: trackpadHeight
                )
                let clipPath = Path(roundedRect: rect, cornerRadius: cornerRadius, style: .continuous)
                
                ForEach(TrackpadEdge.allCases, id: \.self) { edge in
                    let isSelected = edge == selectedEdge
                    let thickness = configuration.bindings[edge]?.bandThickness ?? 0.1
                    
                    Path { path in
                        switch edge {
                        case .top:
                            path.addRect(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * thickness))
                        case .bottom:
                            let h = rect.height * thickness
                            path.addRect(CGRect(x: rect.minX, y: rect.maxY - h, width: rect.width, height: h))
                        case .left:
                            path.addRect(CGRect(x: rect.minX, y: rect.minY, width: rect.width * thickness, height: rect.height))
                        case .right:
                            let w = rect.width * thickness
                            path.addRect(CGRect(x: rect.maxX - w, y: rect.minY, width: w, height: rect.height))
                        }
                    }
                    .fill(isSelected ? GlassColors.accentCyan.opacity(0.45) : Color.white.opacity(0.04))
                    .clipShape(clipPath)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedEdge = edge
                        }
                    }
                }
            }
            .frame(width: trackpadWidth + 20, height: trackpadHeight + 20)

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
