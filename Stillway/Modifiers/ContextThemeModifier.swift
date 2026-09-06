import SwiftUI

struct ContextThemeModifier: ViewModifier {
    @Environment(ThemeEngine.self) private var theme

    func body(content: Content) -> some View {
        content
            .tint(theme.gradient.accentColor)
            .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.blendProgress)
            .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.displayedContext)
    }
}

extension View {
    func contextThemed() -> some View {
        modifier(ContextThemeModifier())
    }
}
