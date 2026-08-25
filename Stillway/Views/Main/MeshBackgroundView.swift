import SwiftUI

struct MeshBackgroundView: View {
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let colors = theme.gradient.bgColors
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 30.0, paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let drift = reduceMotion ? 0.0 : sin(t / 12.0) * 0.06
            ZStack {
                if #available(iOS 18.0, *) {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: meshPoints(drift: drift),
                        colors: meshColors(colors)
                    )
                } else {
                    RadialGradient(colors: colors, center: .center, startRadius: 0, endRadius: 420)
                        .overlay(
                            LinearGradient(colors: [colors[0], .clear], startPoint: .top, endPoint: .bottom)
                        )
                        .scaleEffect(1.05 + drift * 0.15)
                }
                theme.gradient.bgColors[0].opacity(0.25)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: theme.displayedContext)
    }

    private func meshPoints(drift: Double) -> [SIMD2<Float>] {
        let d = Float(drift)
        return [
            .init(0, 0), .init(0.5, 0 + d * 0.2), .init(1, 0),
            .init(0, 0.5), .init(0.5 + d, 0.5 - d), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1 - d * 0.15), .init(1, 1)
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
