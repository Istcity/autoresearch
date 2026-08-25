import SwiftUI

struct PillButtonLabel: View {
    let title: String
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(theme.gradient.accentColor.opacity(0.85))
            )
            .overlay(
                Capsule().stroke(theme.gradient.accentColor.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: theme.gradient.glowColor, radius: 20)
            .shadow(color: theme.gradient.glowColor.opacity(0.5), radius: 40, y: 10)
    }
}

struct PillButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            PillButtonLabel(title: title)
        }
        .hapticButton()
    }
}
