import SwiftUI

struct TimerRing: View {
    var progress: Double
    var seconds: Int
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.08), lineWidth: 2)
            Circle()
                .trim(from: 0, to: min(1, max(0, progress)))
                .stroke(theme.gradient.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            Text(Self.format(seconds))
                .font(.system(size: 42, weight: .medium, design: .monospaced))
                .tracking(-1)
                .foregroundStyle(.white)
        }
        .frame(width: 160, height: 160)
        .accessibilityLabel(Self.format(seconds))
    }

    static func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
