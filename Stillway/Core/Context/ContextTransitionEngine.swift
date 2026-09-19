import Foundation
import SwiftUI

@MainActor
final class ContextTransitionEngine {
    private let theme: ThemeEngine

    init(theme: ThemeEngine) {
        self.theme = theme
    }

    func sweep(to context: AppContext) {
        theme.apply(context: context)
    }
}
