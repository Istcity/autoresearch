import SwiftUI

struct ContextBadge: View {
    let context: AppContext
    var isAutomatic: Bool = false
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        HStack(spacing: 8) {
            Text(lm.string(context.localizationKey).uppercased())
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(2)
                .contentTransition(.opacity)
            if isAutomatic {
                PulsingDot()
                Text(lm.string("ctx_auto").uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(0.5)
                    .opacity(0.85)
                    .contentTransition(.opacity)
            }
        }
        .foregroundStyle(theme.gradient.accentColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(theme.gradient.accentColor.opacity(0.2), in: Capsule())
        .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: context)
        .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.blendProgress)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(lm.string(context.localizationKey)) \(isAutomatic ? lm.string("ctx_auto") : "")")
    }
}
