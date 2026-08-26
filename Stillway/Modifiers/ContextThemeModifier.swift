import SwiftUI

struct ContextThemeModifier: ViewModifier {
    @Environment(ThemeEngine.self) private var theme

    func body(content: Content) -> some View {
        content
            .tint(theme.gradient.accentColor)
            .animation(.easeInOut(duration: 1.2), value: theme.displayedContext)
    }
}

extension View {
    func contextThemed() -> some View {
        modifier(ContextThemeModifier())
    }
}
