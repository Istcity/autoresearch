import SwiftUI

struct PillButton: View {
    let label: String
    var color: Color? = nil
    var isPro: Bool = false
    var action: () -> Void
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        Button {
            HapticEngine.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                if isPro {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 20)
            .background(Capsule().fill((color ?? theme.gradient.accentColor).opacity(0.88)))
            .shadow(color: (color ?? theme.gradient.glowColor).opacity(0.38), radius: 14)
        }
        .buttonStyle(.plain)
    }
}

struct PillButtonLabel: View {
    let title: String
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Capsule().fill(theme.gradient.accentColor.opacity(0.88)))
            .shadow(color: theme.gradient.glowColor.opacity(0.45), radius: 22)
            .shadow(color: theme.gradient.glowColor.opacity(0.28), radius: 40, y: 10)
    }
}
