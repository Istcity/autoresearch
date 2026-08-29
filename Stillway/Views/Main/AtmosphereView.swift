import SwiftUI

/// Full-bleed generative atmosphere — soft, slow, Endel-like depth layers.
struct AtmosphereView: View {
    @Environment(ThemeEngine.self) private var theme
    @Environment(AudioEngine.self) private var audio
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let kind = AtmosphereKind.resolve(soundID: audio.primarySound?.id, context: theme.currentContext)
        let colors = theme.gradient
        let playing = audio.isPlaying

        TimelineView(.animation(minimumInterval: reduceMotion ? 1.0 : 1.0 / 18.0, paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let energy = playing ? 1.0 : 0.45
            Canvas { context, size in
                drawBackdrop(context: context, size: size, colors: colors)
                switch kind {
                case .aurora:
                    drawAurora(context: context, size: size, t: t, colors: colors, energy: energy)
                case .rain:
                    drawRain(context: context, size: size, t: t, colors: colors, energy: energy)
                case .lava:
                    drawLava(context: context, size: size, t: t, colors: colors, energy: energy)
                case .stream:
                    drawStream(context: context, size: size, t: t, colors: colors, energy: energy)
                case .mist:
                    drawMist(context: context, size: size, t: t, colors: colors, energy: energy)
                case .ember:
                    drawEmber(context: context, size: size, t: t, colors: colors, energy: energy)
                }
                drawDepthOrbs(context: context, size: size, t: t, colors: colors, energy: energy)
                drawSoftHorizon(context: context, size: size, t: t, colors: colors, energy: energy)
            }
        }
        .blur(radius: reduceMotion ? 0 : 1.5)
        .animation(.easeInOut(duration: 1.6), value: theme.currentContext)
        .animation(.easeInOut(duration: 1.2), value: audio.primarySound?.id)
        .allowsHitTesting(false)
    }

    // MARK: - Layers

    private func drawBackdrop(context: GraphicsContext, size: CGSize, colors: ContextGradient) {
        let rect = CGRect(origin: .zero, size: size)
        context.fill(
            Path(rect),
            with: .linearGradient(
                Gradient(colors: colors.bgColors),
                startPoint: CGPoint(x: size.width * 0.2, y: 0),
                endPoint: CGPoint(x: size.width * 0.8, y: size.height)
            )
        )
        var glow = context
        glow.addFilter(.blur(radius: 60))
        glow.fill(
            Path(ellipseIn: CGRect(
                x: size.width * 0.15,
                y: size.height * 0.18,
                width: size.width * 0.7,
                height: size.height * 0.45
            )),
            with: .color(colors.glowColor.opacity(0.55))
        )
    }

    private func drawAurora(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        let ribbons = 5
        for i in 0..<ribbons {
            var path = Path()
            let baseY = size.height * (0.22 + Double(i) * 0.09)
            let amp = 28.0 + Double(i) * 10.0
            let speed = 0.12 + Double(i) * 0.03
            let phase = t * speed + Double(i) * 1.3
            path.move(to: CGPoint(x: -20, y: baseY))
            let steps = 28
            for s in 0...steps {
                let x = size.width * CGFloat(s) / CGFloat(steps)
                let y = baseY
                    + sin(Double(s) * 0.45 + phase) * amp * energy
                    + cos(Double(s) * 0.2 + phase * 0.7) * amp * 0.35
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: size.width + 20, y: size.height))
            path.addLine(to: CGPoint(x: -20, y: size.height))
            path.closeSubpath()

            var ribbon = context
            ribbon.opacity = 0.18 + Double(i) * 0.04
            ribbon.addFilter(.blur(radius: 18 + Double(i) * 4))
            ribbon.blendMode = .plusLighter
            let tint = colors.waveColors[i % colors.waveColors.count]
            ribbon.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [tint.opacity(0.05), tint.opacity(0.55), tint.opacity(0.08)]),
                    startPoint: CGPoint(x: 0, y: baseY - 40),
                    endPoint: CGPoint(x: size.width, y: baseY + 80)
                )
            )
        }
    }

    private func drawRain(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        // Soft rain curtain
        let drops = Int(70 * energy + 20)
        var rain = context
        rain.addFilter(.blur(radius: 0.6))
        rain.opacity = 0.55
        for i in 0..<drops {
            let seed = Double(i) * 12.9898
            let x = (sin(seed) * 0.5 + 0.5) * size.width
            let fall = (t * (55 + Double(i % 7) * 12) + seed * 40).truncatingRemainder(dividingBy: size.height + 80)
            let y = fall - 40
            let length = 10.0 + Double(i % 5) * 3.5
            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 1.2, y: y + length))
            rain.stroke(
                path,
                with: .color(colors.waveColors[0].opacity(0.35 + Double(i % 3) * 0.1)),
                style: StrokeStyle(lineWidth: 1.1, lineCap: .round)
            )
        }
        // Ground mist
        var mist = context
        mist.addFilter(.blur(radius: 28))
        mist.opacity = 0.35
        mist.fill(
            Path(ellipseIn: CGRect(x: -40, y: size.height * 0.72, width: size.width + 80, height: size.height * 0.4)),
            with: .color(colors.waveColors[1].opacity(0.4))
        )
    }

    private func drawLava(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        let bands = 4
        for i in 0..<bands {
            var path = Path()
            let baseY = size.height * (0.55 + Double(i) * 0.08)
            let amp = (22.0 + Double(i) * 8) * energy
            let phase = t * (0.18 + Double(i) * 0.04) + Double(i)
            path.move(to: CGPoint(x: 0, y: size.height))
            let steps = 24
            for s in 0...steps {
                let x = size.width * CGFloat(s) / CGFloat(steps)
                let y = baseY + sin(Double(s) * 0.55 + phase) * amp + cos(Double(s) * 0.25 + phase * 1.2) * amp * 0.4
                if s == 0 { path.addLine(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
            }
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.closeSubpath()
            var lava = context
            lava.addFilter(.blur(radius: 14 + Double(i) * 5))
            lava.blendMode = .plusLighter
            lava.opacity = 0.28 - Double(i) * 0.04
            let c = colors.waveColors[min(i, colors.waveColors.count - 1)]
            lava.fill(path, with: .color(c))
        }
        // Rising embers
        for i in 0..<18 {
            let seed = Double(i) * 7.1
            let x = (sin(seed * 1.3) * 0.5 + 0.5) * size.width
            let rise = size.height - ((t * (18 + Double(i % 5) * 6) + seed * 30).truncatingRemainder(dividingBy: size.height * 0.7))
            let r = 2.0 + Double(i % 3)
            var ember = context
            ember.addFilter(.blur(radius: 3))
            ember.opacity = 0.35 * energy
            ember.fill(
                Path(ellipseIn: CGRect(x: x, y: rise, width: r, height: r)),
                with: .color(colors.accentColor)
            )
        }
    }

    private func drawStream(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        let layers = 4
        for i in 0..<layers {
            var path = Path()
            let y0 = size.height * (0.48 + Double(i) * 0.07)
            let amp = (16 + Double(i) * 6) * energy
            let phase = t * (0.22 + Double(i) * 0.05) + Double(i) * 0.9
            let steps = 32
            path.move(to: CGPoint(x: 0, y: y0))
            for s in 0...steps {
                let x = size.width * CGFloat(s) / CGFloat(steps)
                let y = y0 + sin(Double(s) * 0.4 + phase) * amp + sin(Double(s) * 0.15 + phase * 0.5) * amp * 0.5
                path.addLine(to: CGPoint(x: x, y: y))
            }
            var stroke = context
            stroke.addFilter(.blur(radius: 6 + Double(i) * 2))
            stroke.opacity = 0.35 - Double(i) * 0.05
            stroke.blendMode = .plusLighter
            stroke.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: colors.waveColors.map { $0.opacity(0.8) }),
                    startPoint: .zero,
                    endPoint: CGPoint(x: size.width, y: 0)
                ),
                style: StrokeStyle(lineWidth: 10 - CGFloat(i) * 1.5, lineCap: .round)
            )
        }
        // Soft foam highlights
        for i in 0..<12 {
            let seed = Double(i) * 3.7
            let x = ((t * 22 + seed * 50).truncatingRemainder(dividingBy: size.width + 40)) - 20
            let y = size.height * 0.58 + sin(seed + t * 0.3) * 30
            var foam = context
            foam.addFilter(.blur(radius: 5))
            foam.opacity = 0.2 * energy
            foam.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: 18, height: 6)),
                with: .color(.white.opacity(0.5))
            )
        }
    }

    private func drawMist(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        for i in 0..<6 {
            let cx = size.width * (0.2 + Double(i) * 0.12) + sin(t * 0.08 + Double(i)) * 30
            let cy = size.height * (0.3 + Double(i % 3) * 0.15) + cos(t * 0.07 + Double(i)) * 24
            let r = 90.0 + Double(i) * 28
            var cloud = context
            cloud.addFilter(.blur(radius: 40))
            cloud.opacity = (0.12 + Double(i) * 0.03) * energy
            cloud.blendMode = .plusLighter
            cloud.fill(
                Path(ellipseIn: CGRect(x: cx - r / 2, y: cy - r / 3, width: r, height: r * 0.65)),
                with: .color(colors.waveColors[i % colors.waveColors.count])
            )
        }
    }

    private func drawEmber(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        drawMist(context: context, size: size, t: t, colors: colors, energy: energy * 0.7)
        for i in 0..<24 {
            let seed = Double(i) * 5.5
            let x = (sin(seed) * 0.5 + 0.5) * size.width
            let y = size.height * 0.85 - ((t * (10 + Double(i % 4) * 4) + seed * 20).truncatingRemainder(dividingBy: size.height * 0.55))
            let r = 1.5 + Double(i % 4) * 0.8
            var spark = context
            spark.addFilter(.blur(radius: 2.5))
            spark.opacity = 0.4 * energy
            spark.fill(
                Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                with: .color(colors.accentColor)
            )
        }
    }

    private func drawDepthOrbs(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        for i in 0..<3 {
            let cx = size.width * (0.25 + Double(i) * 0.25) + sin(t * 0.05 + Double(i) * 2) * 40
            let cy = size.height * (0.35 + Double(i) * 0.08) + cos(t * 0.04 + Double(i)) * 30
            let r = 70.0 + Double(i) * 20
            var orb = context
            orb.addFilter(.blur(radius: 50))
            orb.opacity = 0.14 * energy
            orb.blendMode = .plusLighter
            orb.fill(
                Path(ellipseIn: CGRect(x: cx - r / 2, y: cy - r / 2, width: r, height: r)),
                with: .color(colors.accentColor)
            )
        }
    }

    private func drawSoftHorizon(context: GraphicsContext, size: CGSize, t: Double, colors: ContextGradient, energy: Double) {
        var path = Path()
        let base = size.height * 0.62
        let amp = 14.0 * energy
        path.move(to: CGPoint(x: 0, y: size.height))
        for s in 0...20 {
            let x = size.width * CGFloat(s) / 20.0
            let y = base + sin(Double(s) * 0.4 + t * 0.15) * amp
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
        var horizon = context
        horizon.addFilter(.blur(radius: 20))
        horizon.opacity = 0.22
        horizon.fill(
            path,
            with: .linearGradient(
                Gradient(colors: [colors.waveColors[0].opacity(0.3), .clear]),
                startPoint: CGPoint(x: 0, y: base - 20),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }
}
