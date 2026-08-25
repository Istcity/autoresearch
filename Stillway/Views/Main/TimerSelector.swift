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
            HStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                    let selected = selection == option
                    Button {
                        onSelect(option)
                    } label: {
                        Text(label(for: option))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(selected ? Color.white : Color.white.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background {
                                if selected {
                                    Capsule()
                                        .fill(theme.gradient.accentColor)
                                        .matchedGeometryEffect(id: "timerPill", in: pillNS)
                                } else {
                                    Capsule().fill(Color.white.opacity(0.08))
                                }
                            }
                    }
                    .hapticButton()
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selection)
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
