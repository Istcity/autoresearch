import SwiftUI

struct StartStopButton: View {
    let isPlaying: Bool
    var action: () -> Void
    @Environment(ThemeEngine.self) private var theme
    @Environment(LocalizationManager.self) private var lm
    @State private var isPressed = false
    @State private var burst = false

    var body: some View {
        let accent = theme.gradient.accentColor
        let glow = theme.gradient.glowColor

        ZStack {
            Circle()
                .fill(glow.opacity(0.15))
                .frame(width: 120)
                .blur(radius: 20)
            Circle()
                .fill(glow.opacity(0.08))
                .frame(width: 160)
                .blur(radius: 40)
                .scaleEffect(burst ? 1.12 : 1)

            Circle()
                .fill(accent.opacity(0.18))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle().stroke(
                        LinearGradient(colors: [accent.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
                )

            Image(systemName: isPlaying ? "waveform" : "play.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(accent)
                .symbolEffect(.variableColor, isActive: isPlaying)
                .offset(x: isPlaying ? 0 : 2)
        }
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        burst = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { burst = false }
                    action()
                }
        )
        .accessibilityLabel(isPlaying ? lm.string("btn_stop") : lm.string("btn_start"))
        .accessibilityAddTraits(.isButton)
    }
}
