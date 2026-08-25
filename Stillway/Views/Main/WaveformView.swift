import SwiftUI

struct WaveformView: View {
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let config = theme.waveConfig
        let colors = theme.gradient.waveColors
        if reduceMotion {
            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                .opacity(config.opacity * 0.45)
                .mask(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
                .padding(.horizontal, 24)
        } else {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let layers = max(1, config.layerCount)
                    for layer in 0..<layers {
                        var path = Path()
                        let layerOffset = Double(layer) * 0.7
                        let amp = config.amplitude * theme.waveAmplitudeScale * (1.0 - Double(layer) * 0.18)
                        let yBase = size.height * 0.55 + CGFloat(layer) * 10
                        path.move(to: CGPoint(x: 0, y: yBase))
                        let steps = Int(size.width / 3)
                        for i in 0...steps {
                            let x = size.width * CGFloat(i) / CGFloat(steps)
                            let phase = t * config.phaseSpeed + layerOffset + Double(layer) * 0.9
                            let y = yBase + CGFloat(sin(Double(x) / size.width * .pi * 2 * config.frequency + phase) * amp)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.addLine(to: CGPoint(x: 0, y: size.height))
                        path.closeSubpath()
                        let gradient = Gradient(colors: colors.map { $0.opacity(config.opacity * (0.55 - Double(layer) * 0.1)) })
                        context.blendMode = .plusLighter
                        context.fill(
                            path,
                            with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height))
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}
