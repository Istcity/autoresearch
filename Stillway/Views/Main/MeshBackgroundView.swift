import SwiftUI

struct MeshBackgroundView: View {
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let colors = theme.gradient.bgColors
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 12.0, paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let drift = reduceMotion ? 0.0 : sin(t / 28.0) * 0.035
            ZStack {
                if #available(iOS 18.0, *) {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: meshPoints(drift: drift),
                        colors: meshColors(colors)
                    )
                    .blur(radius: 18)
                    .scaleEffect(1.08)
                } else {
                    RadialGradient(colors: colors, center: .center, startRadius: 0, endRadius: 460)
                        .overlay(
                            LinearGradient(colors: [colors[0], .clear], startPoint: .top, endPoint: .bottom)
                        )
                        .blur(radius: 12)
                        .scaleEffect(1.08 + drift * 0.12)
                }
                theme.gradient.bgColors[0].opacity(0.18)
            }
        }
        .animation(.easeInOut(duration: 1.4), value: theme.displayedContext)
    }

    private func meshPoints(drift: Double) -> [SIMD2<Float>] {
        let d = Float(drift)
        return [
            .init(0, 0), .init(0.5, 0 + d * 0.15), .init(1, 0),
            .init(0, 0.5), .init(0.5 + d, 0.5 - d * 0.8), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1 - d * 0.12), .init(1, 1)
        ]
    }

    private func meshColors(_ colors: [Color]) -> [Color] {
        let a = colors[safe: 0] ?? .black
        let b = colors[safe: 1] ?? a
        let c = colors[safe: 2] ?? b
        return [a, b, c, b, c, a, c, a, b]
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
