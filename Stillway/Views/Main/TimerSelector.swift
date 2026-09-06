import SwiftUI

struct TimerSelector: View {
    var selection: Int?
    var remainingSeconds: Int?
    var onSelect: (Int?) -> Void
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.lm) private var lm
    @Namespace private var pillNS

    private let options: [Int?] = [15, 30, 45, nil]

    var body: some View {
        VStack(spacing: 12) {
            if let remainingSeconds {
                TimerRing(progress: ringProgress(remainingSeconds), seconds: remainingSeconds)
            }
            HStack(spacing: 6) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    timerPill(option)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.7), value: selection)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func timerPill(_ option: Int?) -> some View {
        let selected = selection == option
        return Button {
            onSelect(option)
        } label: {
            Text(label(for: option))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(selected ? Color.white : Color.white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(pillBackground(selected: selected))
        }
        .buttonStyle(.plain)
        .hapticButton()
    }

    @ViewBuilder
    private func pillBackground(selected: Bool) -> some View {
        if selected {
            Capsule()
                .fill(theme.gradient.accentColor)
                .matchedGeometryEffect(id: "timerPill", in: pillNS)
        } else {
            Capsule().fill(Color.white.opacity(0.08))
        }
    }

    private func label(for option: Int?) -> String {
        if let option { return "\(option)" }
        return lm.string("timer_until_end")
    }

    private func ringProgress(_ remaining: Int) -> Double {
        let total = Double((selection ?? 45) * 60)
        guard total > 0 else { return 0 }
        return 1 - Double(remaining) / total
    }
}
