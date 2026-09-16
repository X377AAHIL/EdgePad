import SwiftUI

struct PreferencesView: View {
    @State private var configuration = ConfigurationStore.shared.load()
    @State private var selection: TrackpadEdge = .right

    var body: some View {
        HSplitView {
            List(TrackpadEdge.allCases, selection: $selection) { edge in
                Label(edge.displayName, systemImage: icon(for: edge))
                    .tag(edge)
            }
            .frame(minWidth: 180)

            if let binding = configuration.defaultProfile.bindings[selection] {
                form(for: selection, binding: binding)
                    .frame(minWidth: 340)
            }
        }
        .frame(minWidth: 560, minHeight: 360)
        .onChange(of: configuration) { _, new in
            ConfigurationStore.shared.save(new)
            NotificationCenter.default.post(name: .edgeConfigurationChanged, object: new)
        }
    }

    private func form(for edge: TrackpadEdge, binding: EdgeBinding) -> some View {
        Form {
            Picker("Action", selection: bind(edge, \.action)) {
                ForEach(EdgeAction.allCases) { action in
                    Text(action.displayName).tag(action)
                }
            }

            Toggle("Invert direction", isOn: bind(edge, \.inverted))

            VStack(alignment: .leading) {
                Text("Band width: \(Int(binding.bandThickness * 100))%")
                Slider(value: bind(edge, \.bandThickness), in: 0.02...0.35)
            }

            VStack(alignment: .leading) {
                Text("Sensitivity")
                Slider(value: bind(edge, \.stepDistance), in: 0.01...0.20)
                Text("Smaller steps = more sensitive")
                    .font(.caption).foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {
                Text("Minimum dwell: \(Int(binding.minimumDwell * 1000)) ms")
                Slider(value: bind(edge, \.minimumDwell), in: 0...0.5)
            }

            VStack(alignment: .leading) {
                Text("Required fingers: \(binding.requiredTouchCount)")
                Stepper("", value: bind(edge, \.requiredTouchCount), in: 1...3)
            }
        }
        .formStyle(.grouped)
    }

    private func bind<V>(_ edge: TrackpadEdge, _ path: WritableKeyPath<EdgeBinding, V>) -> Binding<V> {
        Binding(
            get: { configuration.defaultProfile.bindings[edge]![keyPath: path] },
            set: { configuration.defaultProfile.bindings[edge]![keyPath: path] = $0 }
        )
    }

    private func icon(for edge: TrackpadEdge) -> String {
        switch edge {
        case .left: return "arrow.left.to.line"
        case .right: return "arrow.right.to.line"
        case .top: return "arrow.up.to.line"
        case .bottom: return "arrow.down.to.line"
        }
    }
}

extension Notification.Name {
    static let edgeConfigurationChanged = Notification.Name("edgeConfigurationChanged")
}