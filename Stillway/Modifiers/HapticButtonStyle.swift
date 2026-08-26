import SwiftUI

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.55, dampingFraction: 0.86), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { HapticEngine.tap() }
            }
    }
}

extension View {
    func hapticButton() -> some View {
        buttonStyle(HapticButtonStyle())
    }
}
