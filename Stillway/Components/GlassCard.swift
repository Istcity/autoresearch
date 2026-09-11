import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        content()
            .padding(18)
            .background {
                if reduceTransparency {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(theme.gradient.cardTint)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(theme.gradient.cardTint.opacity(0.28))
                        }
                }
            }
            // Soft edge only — no hard underline / hairline frame.
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.6)
            }
            .shadow(color: .black.opacity(0.22), radius: 18, y: 10)
    }
}
