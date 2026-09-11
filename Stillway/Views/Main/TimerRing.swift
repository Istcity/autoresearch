import SwiftUI

struct TimerRing: View {
    var progress: Double
    var seconds: Int
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.06), lineWidth: 2)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(
                    theme.gradient.accentColor.opacity(0.95),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text(Self.format(seconds))
                .font(.system(size: 44, weight: .light, design: .monospaced))
                .tracking(-1.2)
                .contentTransition(.numericText())
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(width: 168, height: 168)
        .accessibilityLabel(Self.format(seconds))
    }

    static func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
