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
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(theme.gradient.cardBackground)
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(theme.gradient.cardBackground.opacity(0.35))
                        }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [Color.white.opacity(0.15), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
    }
}
