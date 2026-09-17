import SwiftUI

struct PreferencesView: View {
    @State private var configuration: AppProfilesConfiguration = .default
    @State private var selectedEdge: TrackpadEdge?
    @State private var selectedProfile: String = "Global Default"

    private var activeConfig: EdgeConfiguration {
        if selectedProfile == "Global Default" {
            return configuration.defaultProfile
        }
        return configuration.appProfiles[selectedProfile] ?? configuration.defaultProfile
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content: navigation and settings
            mainContent
                .padding(8) // Small padding to the application window
        }
        // Let the mainContent frame (width 320) dictate the size, but allow some height for the topBar
        .frame(width: 320)
        .background(Color.black.opacity(0.01))
        .preferredColorScheme(.dark)
        .onAppear {
            configuration = ConfigurationStore.shared.load()
        }
        .onChange(of: configuration) { _, new in
            ConfigurationStore.shared.save(new)
            NotificationCenter.default.post(name: .edgeConfigurationChanged, object: new)
        }
    }

    // MARK: - Top Bar removed as requested

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 16) {
            CustomSegmentedControl(selection: Binding(
                get: { selectedEdge ?? .top },
                set: { selectedEdge = $0 }
            ))
            .labelsHidden()
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Selected Settings
            if let edge = selectedEdge {
                settingsCard(for: edge)
                    .transition(.opacity)
                    .padding(.horizontal, 16)
                    
                TrackpadVisualizerView(configuration: activeConfig, selectedEdge: edge)
                    .padding(.horizontal, 16)
                
                // Quit button
                HStack {
                    Button {
                        NSApplication.shared.terminate(nil)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "power")
                                .font(.system(size: 10, weight: .medium))
                            Text("Quit")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(GlassColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.06))
                        )
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            } else {
                Spacer()
            }
        }
        .frame(width: 320) // Compact Popover width
        .animation(.easeInOut(duration: 0.2), value: selectedEdge)
        .onAppear {
            if selectedEdge == nil {
                selectedEdge = .top
            }
        }
    }

    // MARK: - Settings Card Builder

    @ViewBuilder
    private func settingsCard(for edge: TrackpadEdge) -> some View {
        if selectedProfile == "Global Default" {
            if configuration.defaultProfile.bindings[edge] != nil {
                EdgeSettingsCard(
                    edge: edge,
                    binding: Binding(
                        get: { configuration.defaultProfile.bindings[edge]! },
                        set: { configuration.defaultProfile.bindings[edge] = $0 }
                    )
                )
            }
        } else {
            if configuration.appProfiles[selectedProfile]?.bindings[edge] != nil {
                EdgeSettingsCard(
                    edge: edge,
                    binding: Binding(
                        get: { configuration.appProfiles[selectedProfile]!.bindings[edge]! },
                        set: { configuration.appProfiles[selectedProfile]!.bindings[edge] = $0 }
                    )
                )
            }
        }
    }
}

extension Notification.Name {
    static let edgeConfigurationChanged = Notification.Name("edgeConfigurationChanged")
}

struct CustomSegmentedControl: View {
    @Binding var selection: TrackpadEdge
    let options: [TrackpadEdge] = TrackpadEdge.allCases
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let segmentWidth = geometry.size.width / CGFloat(options.count)
            let selectedIndex = CGFloat(options.firstIndex(of: selection) ?? 0)
            
            // Calculate the target X position based on selection or active drag
            let targetX = selectedIndex * segmentWidth
            let rawCurrentX = targetX + dragOffset
            let currentX = max(0, min(rawCurrentX, geometry.size.width - segmentWidth))
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
                
                // Active Liquid Glass Indicator
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .glassEffectWithFallback()
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .frame(width: segmentWidth - 4, height: geometry.size.height - 4)
                    .offset(x: currentX + 2) // +2 to account for padding inside track
                    // Add smooth spring animation ONLY when not actively dragging
                    .animation(isDragging ? .interactiveSpring() : .spring(response: 0.4, dampingFraction: 0.7), value: currentX)
                
                // Text Labels
                HStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Text(option.rawValue.capitalized)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(selection == option ? GlassColors.textPrimary : GlassColors.textSecondary)
                            .frame(width: segmentWidth, height: geometry.size.height)
                            .contentShape(Rectangle()) // Make the whole area tappable
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    selection = option
                                }
                            }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let predictedOffset = value.translation.width + (value.predictedEndTranslation.width * 0.3)
                        let newX = targetX + predictedOffset
                        let newIndex = max(0, min(CGFloat(options.count - 1), round(newX / segmentWidth)))
                        
                        isDragging = false
                        dragOffset = 0
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selection = options[Int(newIndex)]
                        }
                    }
            )
        }
        .frame(height: 32)
    }
}
