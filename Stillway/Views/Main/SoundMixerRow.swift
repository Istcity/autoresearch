import SwiftUI

struct SoundMixerRow: View {
    let sound: Sound
    @Binding var volume: Float
    var onTap: () -> Void
    @Environment(LocalizationManager.self) private var lm
    @Environment(ThemeEngine.self) private var theme
    @State private var lastHapticBucket = 0

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: onTap) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lm.string(sound.localizationKey))
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.white)
                            Text(lm.string(sound.localizationKey))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }
                .buttonStyle(.plain)

                VolumeSlider(value: $volume, accent: theme.gradient.accentColor) { newValue in
                    let bucket = Int(newValue * 10)
                    if bucket != lastHapticBucket {
                        lastHapticBucket = bucket
                        HapticEngine.select()
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

struct VolumeSlider: View {
    @Binding var value: Float
    var accent: Color
    var onChange: (Float) -> Void

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 4)
                Capsule()
                    .fill(LinearGradient(colors: [accent, accent.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(4, width * CGFloat(value)), height: 4)
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                    .offset(x: CGFloat(value) * (width - 28))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let next = Float(min(1, max(0, drag.location.x / width)))
                        value = next
                        onChange(next)
                    }
            )
        }
        .frame(height: 28)
        .accessibilityLabel("Volume")
        .accessibilityValue("\(Int(value * 100))%")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: value = min(1, value + 0.1)
            case .decrement: value = max(0, value - 0.1)
            default: break
            }
        }
    }
}
