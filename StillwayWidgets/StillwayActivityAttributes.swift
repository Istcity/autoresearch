import SwiftUI
import ActivityKit

struct StillwayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contextName: String
        var soundName: String
        var remainingSeconds: Int
        var accentColorHex: String
        var isPlaying: Bool
        var atmosphereKind: String
    }

    var sessionName: String
}

extension Color {
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
