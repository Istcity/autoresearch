import SwiftUI

/// Generative visual mode — Endel-like atmospheres keyed to sound/context.
enum AtmosphereKind: String, Codable, CaseIterable, Sendable {
    case aurora
    case rain
    case lava
    case stream
    case mist
    case ember

    static func resolve(soundID: String?, context: AppContext) -> AtmosphereKind {
        switch soundID {
        case "tokyo_rain", "rain_window":
            return .rain
        case "night_forest", "temple_bell", "minka_library":
            return .aurora
        case "istanbul_ferry", "kyoto_bamboo":
            return .stream
        case "deep_train", "shinkansen", "tokyo_metro", "paris_metro":
            return .lava
        case "night_cafe":
            return .ember
        default:
            break
        }
        switch context {
        case .sleep: return .aurora
        case .focus: return .mist
        case .commute: return .lava
        case .reset, .walking: return .stream
        case .deepWork: return .ember
        case .unknown: return .mist
        }
    }

    var symbol: String {
        switch self {
        case .aurora: return "sparkles"
        case .rain: return "cloud.rain.fill"
        case .lava: return "flame.fill"
        case .stream: return "water.waves"
        case .mist: return "aqi.medium"
        case .ember: return "sun.haze.fill"
        }
    }
}
