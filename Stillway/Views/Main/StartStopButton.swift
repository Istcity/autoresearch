import SwiftUI

struct StartStopButton: View {
    let isPlaying: Bool
    var action: () -> Void
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.lm) private var lm
    @State private var isPressed = false
    @State private var burst = false

    var body: some View {
        let accent = theme.gradient.accentColor
        let glow = theme.gradient.glowColor

        ZStack {
            Circle()
                .fill(glow.opacity(isPlaying ? 0.28 : 0.16))
                .frame(width: 128)
                .blur(radius: 24)
            Circle()
                .fill(glow.opacity(isPlaying ? 0.16 : 0.09))
                .frame(width: 176)
                .blur(radius: 56)
                .scaleEffect(burst ? 1.1 : 1)

            Circle()
                .fill(accent.opacity(0.16))
                .frame(width: 84, height: 84)
                .overlay(
                    Circle().stroke(
                        LinearGradient(colors: [accent.opacity(0.45), .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 0.8
                    )
                )

            Image(systemName: isPlaying ? "waveform" : "play.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(accent)
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.variableColor, isActive: isPlaying)
                .offset(x: isPlaying ? 0 : 2)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    withAnimation(.easeOut(duration: 0.9)) { burst = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        withAnimation(.easeInOut(duration: 1.2)) { burst = false }
                    }
                    action()
                }
        )
        .accessibilityLabel(isPlaying ? lm.string("btn_stop") : lm.string("btn_start"))
        .accessibilityAddTraits(.isButton)
    }
}
