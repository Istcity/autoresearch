import SwiftUI

struct ContextBadge: View {
    let context: AppContext
    var isAutomatic: Bool = false
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        HStack(spacing: 6) {
            Text(lm.string(context.localizationKey).uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .tracking(1.4)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.opacity)
            if isAutomatic {
                PulsingDot()
                Text(lm.string("ctx_auto").uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.4)
                    .opacity(0.85)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.opacity)
            }
        }
        .foregroundStyle(theme.gradient.accentColor)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .fixedSize(horizontal: true, vertical: true)
        .background(theme.gradient.accentColor.opacity(0.2), in: Capsule())
        .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: context)
        .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.blendProgress)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lm.string(context.localizationKey)) \(isAutomatic ? lm.string("ctx_auto") : "")")
    }
}
