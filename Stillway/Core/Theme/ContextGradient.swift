import SwiftUI

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
}
