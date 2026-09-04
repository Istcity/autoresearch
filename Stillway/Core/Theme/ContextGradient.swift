import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ContextGradient: Equatable, Sendable {
    let bgColors: [Color]
    let waveColors: [Color]
    let accentColor: Color
    let glowColor: Color
    let cardTint: Color

    var cardBackground: Color { cardTint }

    static func gradient(for context: AppContext) -> ContextGradient {
        switch context {
        case .commute:
            return ContextGradient(
                bgColors: [Color(hex: 0x020818), Color(hex: 0x0D1B4D), Color(hex: 0x1B0D4D)],
                waveColors: [Color(hex: 0x1B3FDB), Color(hex: 0x6B21DB), Color(hex: 0x9B59B6)],
                accentColor: Color(hex: 0x4169E1),
                glowColor: Color(hex: 0x1B3FDB).opacity(0.4),
                cardTint: Color(hex: 0x0D1B4D).opacity(0.6)
            )
        case .focus:
            return ContextGradient(
                bgColors: [Color(hex: 0x020C18), Color(hex: 0x041B2D), Color(hex: 0x062040)],
                waveColors: [Color(hex: 0x0A84FF), Color(hex: 0x0066CC), Color(hex: 0x00B4A0)],
                accentColor: Color(hex: 0x0A84FF),
                glowColor: Color(hex: 0x0A84FF).opacity(0.35),
                cardTint: Color(hex: 0x041B2D).opacity(0.6)
            )
        case .sleep:
            return ContextGradient(
                bgColors: [Color(hex: 0x050010), Color(hex: 0x0F0226), Color(hex: 0x1A0533)],
                waveColors: [Color(hex: 0x5E5CE6), Color(hex: 0x7C3AED), Color(hex: 0x4C1D95)],
                accentColor: Color(hex: 0x5E5CE6),
                glowColor: Color(hex: 0x5E5CE6).opacity(0.35),
                cardTint: Color(hex: 0x0F0226).opacity(0.65)
            )
        case .reset:
            return ContextGradient(
                bgColors: [Color(hex: 0x180800), Color(hex: 0x2D1200), Color(hex: 0x3D1A00)],
                waveColors: [Color(hex: 0xFF9F0A), Color(hex: 0xFF6B35), Color(hex: 0xFF453A)],
                accentColor: Color(hex: 0xFF9F0A),
                glowColor: Color(hex: 0xFF9F0A).opacity(0.4),
                cardTint: Color(hex: 0x2D1200).opacity(0.6)
            )
        case .walking:
            return ContextGradient(
                bgColors: [Color(hex: 0x001208), Color(hex: 0x002010), Color(hex: 0x003018)],
                waveColors: [Color(hex: 0x30D158), Color(hex: 0x34C759), Color(hex: 0x00BFB3)],
                accentColor: Color(hex: 0x30D158),
                glowColor: Color(hex: 0x30D158).opacity(0.35),
                cardTint: Color(hex: 0x002010).opacity(0.6)
            )
        case .deepWork:
            return ContextGradient(
                bgColors: [Color(hex: 0x150000), Color(hex: 0x2D0000), Color(hex: 0x3D0A0A)],
                waveColors: [Color(hex: 0xFF453A), Color(hex: 0xFF2D20), Color(hex: 0xC0000A)],
                accentColor: Color(hex: 0xFF453A),
                glowColor: Color(hex: 0xFF453A).opacity(0.4),
                cardTint: Color(hex: 0x2D0000).opacity(0.65)
            )
        case .unknown:
            return ContextGradient(
                bgColors: [Color(hex: 0x050505), Color(hex: 0x0A0A0A), Color(hex: 0x111111)],
                waveColors: [Color(hex: 0x48484A), Color(hex: 0x636366), Color(hex: 0x48484A)],
                accentColor: Color(hex: 0x8A8A8E),
                glowColor: Color(hex: 0x8A8A8E).opacity(0.25),
                cardTint: Color(hex: 0x1C1C1E).opacity(0.6)
            )
        }
    }

    static func `for`(_ context: AppContext) -> ContextGradient {
        gradient(for: context)
    }

    /// Soft crossfade between two theme palettes (t = 0...1).
    static func blended(from: ContextGradient, to: ContextGradient, t: Double) -> ContextGradient {
        let t = min(1, max(0, t))
        if t <= 0.001 { return from }
        if t >= 0.999 { return to }
        return ContextGradient(
            bgColors: zipPad(from.bgColors, to.bgColors).map { $0.mix(with: $1, t: t) },
            waveColors: zipPad(from.waveColors, to.waveColors).map { $0.mix(with: $1, t: t) },
            accentColor: from.accentColor.mix(with: to.accentColor, t: t),
            glowColor: from.glowColor.mix(with: to.glowColor, t: t),
            cardTint: from.cardTint.mix(with: to.cardTint, t: t)
        )
    }

    private static func zipPad(_ a: [Color], _ b: [Color]) -> [(Color, Color)] {
        let count = max(a.count, b.count)
        return (0..<count).map { i in
            (a[min(i, a.count - 1)], b[min(i, b.count - 1)])
        }
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    init(hexString: String) {
        var hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.count == 6 { hex = "FF" + hex }
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a = Double((int >> 24) & 0xFF) / 255
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func mix(with other: Color, t: Double) -> Color {
        let t = min(1, max(0, t))
        #if canImport(UIKit)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        guard UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              UIColor(other).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        else {
            return t < 0.5 ? self : other
        }
        return Color(
            .sRGB,
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
        #else
        return t < 0.5 ? self : other
        #endif
    }
}
