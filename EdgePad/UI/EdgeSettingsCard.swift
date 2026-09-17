import SwiftUI

struct EdgeSettingsCard: View {
    let edge: TrackpadEdge
    @Binding var binding: EdgeBinding

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: binding.action.systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(GlassColors.accentCyan)

                Text(edge.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(GlassColors.textPrimary)

                Spacer()
            }

            Divider().opacity(0.3)

            // Action Picker
            HStack {
                Text("Action")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(GlassColors.textSecondary)
                Spacer()
                Picker("", selection: $binding.action) {
                    ForEach(EdgeAction.allCases) { action in
                        Text(action.displayName).tag(action)
                    }
                }
                .labelsHidden()
                .frame(width: 140)
            }

            // Finger Count
            HStack {
                Text("Fingers")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(GlassColors.textSecondary)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(1...2, id: \.self) { count in
                        Button {
                            // Only animate if reduced motion is off, or use a much subtler one
                            withAnimation(GlassAnimation.hoverScale) {
                                binding.requiredTouchCount = count
                            }
                        } label: {
                            HStack(spacing: 2) {
                                ForEach(0..<count, id: \.self) { _ in
                                    Image(systemName: "hand.point.up.fill")
                                        .font(.system(size: 9))
                                }
                            }
                            .frame(width: 36, height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(binding.requiredTouchCount == count
                                          ? GlassColors.accentCyan.opacity(0.3)
                                          : Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        binding.requiredTouchCount == count
                                        ? GlassColors.accentCyan.opacity(0.5)
                                        : Color.white.opacity(0.1),
                                        lineWidth: 0.5
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(
                            binding.requiredTouchCount == count
                            ? GlassColors.accentCyan
                            : GlassColors.textSecondary
                        )
                        .accessibilityLabel("\(count) finger\(count > 1 ? "s" : "")")
                        .accessibilityAddTraits(binding.requiredTouchCount == count ? .isSelected : [])
                    }
                }
            }

            // Modifiers
            HStack(spacing: 12) {
                Toggle(isOn: $binding.requiresOption) {
                    Text("⌥ Option")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                }
                .toggleStyle(.checkbox)

                Toggle(isOn: $binding.requiresCommand) {
                    Text("⌘ Command")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                }
                .toggleStyle(.checkbox)
            }
            .foregroundStyle(GlassColors.textSecondary)

            // Invert Toggle
            Toggle(isOn: $binding.inverted) {
                Text("Invert direction")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(GlassColors.textSecondary)
            }
            .toggleStyle(.checkbox)

            Divider().opacity(0.3)

            // Sensitivity Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Sensitivity")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(GlassColors.textSecondary)
                    Spacer()
                    Text(String(format: "%.3f", binding.stepDistance))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(GlassColors.accentCyan.opacity(0.7))
                }
                Slider(value: $binding.stepDistance, in: 0.01...0.20)
                    .tint(GlassColors.accentCyan)
            }

            // Edge Hitbox Width
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Edge Width")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(GlassColors.textSecondary)
                    Spacer()
                    Text("\(Int(binding.bandThickness * 100))%")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(GlassColors.accentCyan.opacity(0.7))
                }
                Slider(value: $binding.bandThickness, in: 0.02...0.35)
                    .tint(GlassColors.accentCyan)
            }

            // Dwell Time
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Dwell Time")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(GlassColors.textSecondary)
                    Spacer()
                    Text("\(Int(binding.minimumDwell * 1000)) ms")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(GlassColors.accentCyan.opacity(0.7))
                }
                Slider(value: $binding.minimumDwell, in: 0...0.5)
                    .tint(GlassColors.accentCyan)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.1))
        }
    }
}
