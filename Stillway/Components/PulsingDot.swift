import SwiftUI

struct PulsingDot: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    var body: some View {
        ZStack {
            if !reduceMotion {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.green.opacity(0.45 - Double(i) * 0.12), lineWidth: 1)
                        .frame(width: 8 + CGFloat(i) * 8, height: 8 + CGFloat(i) * 8)
                        .scaleEffect(pulse ? 1.35 : 0.85)
                        .opacity(pulse ? 0.15 : 0.7)
                        .animation(
                            .easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(Double(i) * 0.18),
                            value: pulse
                        )
                }
            }
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        }
        .frame(width: 22, height: 22)
        .onAppear { pulse = true }
        .accessibilityHidden(true)
    }
}
