import SwiftUI

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .transaction { transaction in
                if reduceMotion {
                    transaction.animation = nil
                }
            }
    }
}

extension View {
    func respectReduceMotion() -> some View {
        modifier(ReduceMotionModifier())
    }
}
