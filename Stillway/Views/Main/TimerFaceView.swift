import SwiftUI

/// Living timer faces — sand, water, sundial, moon… progress = elapsed 0…1.
struct TimerFaceView: View {
    let kind: TimerFaceKind
    /// Elapsed fraction (0 = full time left, 1 = finished).
    var progress: Double
    var seconds: Int
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var remaining: Double { max(0, min(1, 1 - progress)) }
    private var accent: Color { theme.gradient.accentColor }
    private var glow: Color { theme.gradient.glowColor }

    var body: some View {
        ZStack {
            faceCanvas
            Text(TimerRing.format(seconds))
                .font(.system(size: 28, weight: .light, design: .monospaced))
                .tracking(-0.8)
                .contentTransition(.numericText())
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.35), radius: 8, y: 2)
        }
        .frame(width: 176, height: 176)
        .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: kind)
        .accessibilityLabel(TimerRing.format(seconds))
    }

    @ViewBuilder
    private var faceCanvas: some View {
        if reduceMotion {
            staticFace
        } else {
            TimelineView(.periodic(from: .now, by: 1.0 / 20.0)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                Canvas { context, size in
                    draw(kind: kind, context: &context, size: size, t: t)
                }
            }
        }
    }

    private var staticFace: some View {
        Canvas { context, size in
            var ctx = context
            draw(kind: kind, context: &ctx, size: size, t: 0)
        }
    }

    private func draw(kind: TimerFaceKind, context: inout GraphicsContext, size: CGSize, t: Double) {
        switch kind {
        case .ring: drawRing(context: &context, size: size)
        case .hourglass: drawHourglass(context: &context, size: size, t: t)
        case .waterDrop: drawWaterDrop(context: &context, size: size, t: t)
        case .classic: drawClassic(context: &context, size: size, t: t)
        case .sundial: drawSundial(context: &context, size: size, t: t)
        case .moon: drawMoon(context: &context, size: size, t: t)
        case .tide: drawTide(context: &context, size: size, t: t)
        case .ember: drawEmber(context: &context, size: size, t: t)
        case .mist: drawMist(context: &context, size: size, t: t)
        case .breath: drawBreath(context: &context, size: size, t: t)
        }
    }

    // MARK: - Ring

    private func drawRing(context: inout GraphicsContext, size: CGSize) {
        let r = min(size.width, size.height) * 0.46
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        var track = Path()
        track.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
        context.stroke(track, with: .color(.white.opacity(0.06)), lineWidth: 2)

        var arc = Path()
        arc.addArc(center: c, radius: r, startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * progress), clockwise: false)
        context.stroke(arc, with: .color(accent.opacity(0.95)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    // MARK: - Hourglass (sand flows)

    private func drawHourglass(context: inout GraphicsContext, size: CGSize, t: Double) {
        let mid = CGPoint(x: size.width / 2, y: size.height / 2)
        let w = size.width * 0.34
        let h = size.height * 0.42

        // Glass silhouette
        var glass = Path()
        glass.move(to: CGPoint(x: mid.x - w, y: mid.y - h))
        glass.addLine(to: CGPoint(x: mid.x + w, y: mid.y - h))
        glass.addLine(to: CGPoint(x: mid.x + 4, y: mid.y))
        glass.addLine(to: CGPoint(x: mid.x + w, y: mid.y + h))
        glass.addLine(to: CGPoint(x: mid.x - w, y: mid.y + h))
        glass.addLine(to: CGPoint(x: mid.x - 4, y: mid.y))
        glass.closeSubpath()
        context.stroke(glass, with: .color(.white.opacity(0.18)), lineWidth: 1.2)

        // Top sand (remaining)
        let topFill = remaining
        if topFill > 0.01 {
            var top = Path()
            let topY = mid.y - h + CGFloat(1 - topFill) * h * 0.92
            top.move(to: CGPoint(x: mid.x - w * 0.88, y: topY))
            top.addLine(to: CGPoint(x: mid.x + w * 0.88, y: topY))
            top.addLine(to: CGPoint(x: mid.x + 3, y: mid.y - 2))
            top.addLine(to: CGPoint(x: mid.x - 3, y: mid.y - 2))
            top.closeSubpath()
            context.fill(top, with: .color(accent.opacity(0.55)))
        }

        // Bottom sand (elapsed)
        let bottomFill = progress
        if bottomFill > 0.01 {
            var bottom = Path()
            let base = mid.y + h
            let sandH = CGFloat(bottomFill) * h * 0.9
            bottom.move(to: CGPoint(x: mid.x - w * 0.9, y: base))
            bottom.addLine(to: CGPoint(x: mid.x + w * 0.9, y: base))
            bottom.addLine(to: CGPoint(x: mid.x + w * 0.55, y: base - sandH))
            bottom.addLine(to: CGPoint(x: mid.x - w * 0.55, y: base - sandH))
            bottom.closeSubpath()
            context.fill(bottom, with: .color(accent.opacity(0.7)))
        }

        // Falling grains
        if remaining > 0.02, progress < 0.98 {
            for i in 0..<8 {
                let phase = t * 2.4 + Double(i) * 0.37
                let fall = (phase.truncatingRemainder(dividingBy: 1.0))
                let y = mid.y - 8 + CGFloat(fall) * 36
                let x = mid.x + sin(phase * 3) * 1.5
                let grain = Path(ellipseIn: CGRect(x: x - 1.1, y: y - 1.1, width: 2.2, height: 2.2))
                context.fill(grain, with: .color(accent.opacity(0.85)))
            }
        }
    }

    // MARK: - Water drop / clepsydra

    private func drawWaterDrop(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height * 0.48)
        let scale = min(size.width, size.height) * 0.38

        var drop = Path()
        drop.move(to: CGPoint(x: c.x, y: c.y - scale))
        drop.addCurve(
            to: CGPoint(x: c.x + scale * 0.72, y: c.y + scale * 0.15),
            control1: CGPoint(x: c.x + scale * 0.15, y: c.y - scale * 0.35),
            control2: CGPoint(x: c.x + scale * 0.72, y: c.y - scale * 0.2)
        )
        drop.addQuadCurve(
            to: CGPoint(x: c.x - scale * 0.72, y: c.y + scale * 0.15),
            control: CGPoint(x: c.x, y: c.y + scale * 1.05)
        )
        drop.addCurve(
            to: CGPoint(x: c.x, y: c.y - scale),
            control1: CGPoint(x: c.x - scale * 0.72, y: c.y - scale * 0.2),
            control2: CGPoint(x: c.x - scale * 0.15, y: c.y - scale * 0.35)
        )
        context.stroke(drop, with: .color(.white.opacity(0.2)), lineWidth: 1.1)

        // Water level rises with elapsed? Prefer drain = remaining water
        let level = remaining
        var clipped = context
        clipped.clip(to: drop)
        let waterTop = c.y + scale * 0.95 - CGFloat(level) * scale * 1.7
        let wave = sin(t * 1.6) * 3
        var water = Path()
        water.move(to: CGPoint(x: 0, y: size.height))
        water.addLine(to: CGPoint(x: size.width, y: size.height))
        water.addLine(to: CGPoint(x: size.width, y: waterTop + wave))
        for x in stride(from: size.width, through: 0, by: -6) {
            let y = waterTop + sin(t * 1.8 + x * 0.08) * 3.5
            water.addLine(to: CGPoint(x: x, y: y))
        }
        water.closeSubpath()
        clipped.fill(water, with: .linearGradient(
            Gradient(colors: [accent.opacity(0.75), glow.opacity(0.35)]),
            startPoint: CGPoint(x: c.x, y: waterTop),
            endPoint: CGPoint(x: c.x, y: size.height)
        ))

        // Drip when time remains
        if remaining > 0.05 {
            let dripY = c.y + scale * 0.85 + CGFloat((t * 1.2).truncatingRemainder(dividingBy: 1.0)) * 18
            let drip = Path(ellipseIn: CGRect(x: c.x - 2, y: dripY, width: 4, height: 5))
            context.fill(drip, with: .color(accent.opacity(0.7)))
        }
    }

    // MARK: - Classic analog

    private func drawClassic(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let r = min(size.width, size.height) * 0.44
        var rim = Path()
        rim.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
        context.stroke(rim, with: .color(.white.opacity(0.16)), lineWidth: 1.4)

        for i in 0..<12 {
            let a = Double(i) / 12 * .pi * 2 - .pi / 2
            let outer = CGPoint(x: c.x + cos(a) * r * 0.92, y: c.y + sin(a) * r * 0.92)
            let inner = CGPoint(x: c.x + cos(a) * r * (i % 3 == 0 ? 0.78 : 0.86), y: c.y + sin(a) * r * (i % 3 == 0 ? 0.78 : 0.86))
            var tick = Path()
            tick.move(to: inner)
            tick.addLine(to: outer)
            context.stroke(tick, with: .color(.white.opacity(i % 3 == 0 ? 0.45 : 0.2)), lineWidth: i % 3 == 0 ? 1.6 : 0.8)
        }

        // Hands represent remaining time (minute-style sweep of remaining)
        let angle = -Double.pi / 2 + Double.pi * 2 * progress
        let handLen = r * 0.72
        var hand = Path()
        hand.move(to: c)
        hand.addLine(to: CGPoint(x: c.x + cos(angle) * handLen, y: c.y + sin(angle) * handLen))
        context.stroke(hand, with: .color(accent), style: StrokeStyle(lineWidth: 2.2, lineCap: .round))

        // Soft second shimmer
        let shimmer = -Double.pi / 2 + t.truncatingRemainder(dividingBy: 60) / 60 * .pi * 2
        var sec = Path()
        sec.move(to: c)
        sec.addLine(to: CGPoint(x: c.x + cos(shimmer) * r * 0.8, y: c.y + sin(shimmer) * r * 0.8))
        context.stroke(sec, with: .color(accent.opacity(0.35)), style: StrokeStyle(lineWidth: 0.8, lineCap: .round))

        let hub = Path(ellipseIn: CGRect(x: c.x - 3, y: c.y - 3, width: 6, height: 6))
        context.fill(hub, with: .color(accent))
    }

    // MARK: - Sundial

    private func drawSundial(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height * 0.58)
        let r = min(size.width, size.height) * 0.4
        var plate = Path()
        plate.addEllipse(in: CGRect(x: c.x - r, y: c.y - r * 0.55, width: r * 2, height: r * 1.1))
        context.fill(plate, with: .color(.white.opacity(0.04)))
        context.stroke(plate, with: .color(.white.opacity(0.14)), lineWidth: 1)

        // Hour marks on arc
        for i in 0..<7 {
            let a = Double.pi * (0.15 + Double(i) / 6 * 0.7)
            let p = CGPoint(x: c.x + cos(a) * r * 0.85, y: c.y - sin(a) * r * 0.45)
            context.fill(Path(ellipseIn: CGRect(x: p.x - 1.5, y: p.y - 1.5, width: 3, height: 3)), with: .color(.white.opacity(0.35)))
        }

        // Sun
        let sunA = Double.pi * (0.15 + remaining * 0.7)
        let sun = CGPoint(x: c.x + cos(sunA) * r * 0.95, y: c.y - sin(sunA) * r * 0.55 - 8)
        var sunGlow = context
        sunGlow.addFilter(.blur(radius: 8))
        sunGlow.fill(Path(ellipseIn: CGRect(x: sun.x - 10, y: sun.y - 10, width: 20, height: 20)), with: .color(accent.opacity(0.45)))
        context.fill(Path(ellipseIn: CGRect(x: sun.x - 5, y: sun.y - 5, width: 10, height: 10)), with: .color(accent))

        // Gnomon shadow
        var shadow = Path()
        shadow.move(to: c)
        shadow.addLine(to: CGPoint(x: sun.x + (c.x - sun.x) * 0.3, y: c.y + 6))
        shadow.addLine(to: CGPoint(x: c.x + 8, y: c.y + 4))
        shadow.closeSubpath()
        context.fill(shadow, with: .color(.black.opacity(0.35)))

        // Gnomon
        var gnomon = Path()
        gnomon.move(to: CGPoint(x: c.x, y: c.y + 2))
        gnomon.addLine(to: CGPoint(x: c.x, y: c.y - r * 0.35))
        context.stroke(gnomon, with: .color(.white.opacity(0.5)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        _ = t
    }

    // MARK: - Moon

    private func drawMoon(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let r = min(size.width, size.height) * 0.36
        let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
        context.fill(Path(ellipseIn: rect), with: .color(accent.opacity(0.18)))

        // Crescent with even-odd cutout — phase follows remaining time
        let offset = CGFloat(progress) * r * 1.55
        var crescent = Path(ellipseIn: rect)
        crescent.addEllipse(in: CGRect(x: c.x - r + offset, y: c.y - r * 0.92, width: r * 2, height: r * 1.84))
        context.fill(crescent, with: .color(accent.opacity(0.82)), style: FillStyle(eoFill: true))

        for i in 0..<6 {
            let a = Double(i) * 1.1 + t * 0.05
            let sr = r * 1.15
            let p = CGPoint(x: c.x + cos(a) * sr, y: c.y + sin(a) * sr * 0.9)
            context.fill(Path(ellipseIn: CGRect(x: p.x - 1, y: p.y - 1, width: 2, height: 2)), with: .color(.white.opacity(0.35)))
        }
    }

    // MARK: - Tide

    private func drawTide(context: inout GraphicsContext, size: CGSize, t: Double) {
        var rim = Path()
        rim.addEllipse(in: CGRect(x: 8, y: 8, width: size.width - 16, height: size.height - 16))
        context.stroke(rim, with: .color(.white.opacity(0.12)), lineWidth: 1)

        var clipped = context
        clipped.clip(to: rim)
        let level = size.height * (0.22 + CGFloat(remaining) * 0.55)
        var water = Path()
        water.move(to: CGPoint(x: 0, y: size.height))
        water.addLine(to: CGPoint(x: size.width, y: size.height))
        water.addLine(to: CGPoint(x: size.width, y: level))
        for x in stride(from: size.width, through: 0, by: -5) {
            let y = level + sin(t * 1.4 + Double(x) * 0.05) * 5
                + sin(t * 0.7 + Double(x) * 0.02) * 3
            water.addLine(to: CGPoint(x: x, y: y))
        }
        water.closeSubpath()
        clipped.fill(water, with: .linearGradient(
            Gradient(colors: [accent.opacity(0.55), glow.opacity(0.25)]),
            startPoint: CGPoint(x: size.width / 2, y: level),
            endPoint: CGPoint(x: size.width / 2, y: size.height)
        ))
    }

    // MARK: - Ember

    private func drawEmber(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height * 0.58)
        let base = remaining
        for i in 0..<5 {
            let pulse = 0.85 + 0.15 * sin(t * (1.2 + Double(i) * 0.3))
            let rr = CGFloat(base) * (28 + CGFloat(i) * 10) * pulse
            var glowCtx = context
            glowCtx.addFilter(.blur(radius: 6 + Double(i) * 3))
            glowCtx.fill(
                Path(ellipseIn: CGRect(x: c.x - rr, y: c.y - rr * 1.1, width: rr * 2, height: rr * 2.1)),
                with: .color(accent.opacity(0.18 - Double(i) * 0.02))
            )
        }
        let core = CGFloat(base) * 22
        context.fill(
            Path(ellipseIn: CGRect(x: c.x - core, y: c.y - core * 0.9, width: core * 2, height: core * 1.8)),
            with: .color(accent.opacity(0.85))
        )
        // Rising sparks
        for i in 0..<6 {
            let phase = (t * 0.6 + Double(i) * 0.2).truncatingRemainder(dividingBy: 1.0)
            let y = c.y - CGFloat(phase) * 50
            let x = c.x + sin(t + Double(i)) * 12
            context.fill(Path(ellipseIn: CGRect(x: x - 1.2, y: y - 1.2, width: 2.4, height: 2.4)), with: .color(accent.opacity(1 - phase)))
        }
    }

    // MARK: - Mist

    private func drawMist(context: inout GraphicsContext, size: CGSize, t: Double) {
        let veil = remaining
        for i in 0..<4 {
            let y = size.height * (0.25 + Double(i) * 0.15) + sin(t * 0.5 + Double(i)) * 6
            var band = Path()
            band.addEllipse(in: CGRect(
                x: size.width * 0.05,
                y: y,
                width: size.width * 0.9,
                height: 28 + CGFloat(i) * 4
            ))
            var mist = context
            mist.addFilter(.blur(radius: 10))
            mist.fill(band, with: .color(.white.opacity(0.08 + veil * 0.12)))
        }
        var ring = Path()
        let r = min(size.width, size.height) * 0.42
        ring.addEllipse(in: CGRect(x: size.width / 2 - r, y: size.height / 2 - r, width: r * 2, height: r * 2))
        context.stroke(ring, with: .color(accent.opacity(0.25 + progress * 0.4)), lineWidth: 1.2)
    }

    // MARK: - Breath orb

    private func drawBreath(context: inout GraphicsContext, size: CGSize, t: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let breath = 0.92 + 0.08 * sin(t * 0.7)
        let r = min(size.width, size.height) * 0.38 * breath
        var outer = context
        outer.addFilter(.blur(radius: 16))
        outer.fill(Path(ellipseIn: CGRect(x: c.x - r * 1.15, y: c.y - r * 1.15, width: r * 2.3, height: r * 2.3)), with: .color(glow.opacity(0.3)))

        // Fill from bottom with remaining
        var orb = Path()
        orb.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
        context.stroke(orb, with: .color(.white.opacity(0.15)), lineWidth: 1)
        var clipped = context
        clipped.clip(to: orb)
        let fillTop = c.y + r - CGFloat(remaining) * r * 2
        clipped.fill(
            Path(CGRect(x: 0, y: fillTop, width: size.width, height: size.height)),
            with: .linearGradient(
                Gradient(colors: [accent.opacity(0.7), accent.opacity(0.2)]),
                startPoint: CGPoint(x: c.x, y: fillTop),
                endPoint: CGPoint(x: c.x, y: c.y + r)
            )
        )
    }
}
