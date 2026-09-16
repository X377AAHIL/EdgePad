import SwiftUI
import AppKit

struct TouchCapture: NSViewRepresentable {
    var onTouches: (Set<NSTouch>) -> Void

    func makeNSView(context: Context) -> TrackpadTouchView {
        let view = TrackpadTouchView()
        view.onTouches = onTouches
        return view
    }

    func updateNSView(_ nsView: TrackpadTouchView, context: Context) {
        nsView.onTouches = onTouches
    }
}

struct TouchDebugView: View {
    @State private var dots: [CGPoint] = []
    @State private var band: CGFloat = 0.15

    var body: some View {
        VStack(spacing: 12) {
            Text("Touch the trackpad. Dots follow your fingers.")
                .font(.callout)

            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    Rectangle().fill(.quaternary)

                    Rectangle().fill(.blue.opacity(0.18))
                        .frame(width: geo.size.width * band)
                        .frame(maxHeight: .infinity, alignment: .leading)
                    Rectangle().fill(.blue.opacity(0.18))
                        .frame(width: geo.size.width * band)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    Rectangle().fill(.green.opacity(0.18))
                        .frame(height: geo.size.height * band)
                        .frame(maxWidth: .infinity, alignment: .top)
                    Rectangle().fill(.green.opacity(0.18))
                        .frame(height: geo.size.height * band)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                    ForEach(Array(dots.enumerated()), id: \.offset) { _, p in
                        Circle()
                            .fill(.orange)
                            .frame(width: 22, height: 22)
                            .position(x: p.x * geo.size.width, y: (1 - p.y) * geo.size.height)
                    }
                }
            }
            .aspectRatio(1.6, contentMode: .fit)

            TouchCapture { touches in
                dots = touches
                    .filter { $0.phase != .ended && $0.phase != .cancelled }
                    .map(\.normalizedPosition)
            }
            .frame(height: 0)
        }
        .padding()
        .frame(minWidth: 520, minHeight: 420)
    }
}