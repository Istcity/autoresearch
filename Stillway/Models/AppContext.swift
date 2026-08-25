import Foundation

enum AppContext: String, Codable, CaseIterable, Identifiable, Sendable {
    case commute
    case focus
    case sleep
    case reset
    case walking
    case deepwork
    case unknown

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .commute: return "ctx_commute"
        case .focus: return "ctx_focus"
        case .sleep: return "ctx_sleep"
        case .reset: return "ctx_reset"
        case .walking: return "ctx_walking"
        case .deepwork: return "ctx_deepwork"
        case .unknown: return "ctx_unknown"
        }
    }

    var defaultSoundID: String {
        switch self {
        case .commute: return "tokyo_metro"
        case .focus: return "tokyo_rain"
        case .sleep: return "night_forest"
        case .reset: return "kyoto_bamboo"
        case .walking: return "rain_window"
        case .deepwork: return "deep_train"
        case .unknown: return "tokyo_rain"
        }
    }
}

enum TriggerType: String, Codable, Sendable {
    case automatic
    case suggested
    case manual
}
