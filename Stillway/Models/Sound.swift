import Foundation

enum SoundRegion: String, Codable, Sendable {
    case JP, FR, UK, US, TR, NATURE, URBAN

    var flag: String {
        switch self {
        case .JP: return "🇯🇵"
        case .FR: return "🇫🇷"
        case .UK: return "🇬🇧"
        case .US: return "🇺🇸"
        case .TR: return "🇹🇷"
        case .NATURE: return "🌿"
        case .URBAN: return "🏙"
        }
    }
}

/// Selectable binaural / carrier tone layer for focus and sleep mixes.
enum BinauralTone: String, CaseIterable, Codable, Sendable, Identifiable, Hashable {
    case off
    case delta
    case theta
    case alpha
    case beta

    var id: String { rawValue }

    /// Beat frequency in Hz (carrier offset). `off` is silent.
    var beatHz: Double {
        switch self {
        case .off: return 0
        case .delta: return 2.5
        case .theta: return 6
        case .alpha: return 10
        case .beta: return 16
        }
    }

    var localizationKey: String {
        switch self {
        case .off: return "binaural_off"
        case .delta: return "binaural_delta"
        case .theta: return "binaural_theta"
        case .alpha: return "binaural_alpha"
        case .beta: return "binaural_beta"
        }
    }
}

struct Sound: Identifiable, Equatable, Hashable, Codable, Sendable {
    let id: String
    let localizationKey: String
    let fileName: String
    let context: AppContext
    let region: SoundRegion
    let isFree: Bool
    let defaultVolume: Float

    var bundleResource: String { fileName }

    /// SF Symbol used in the sound picker and mixer.
    var iconName: String {
        switch id {
        case "tokyo_metro", "paris_metro":
            return "tram.fill"
        case "shinkansen", "deep_train":
            return "train.side.front.car"
        case "istanbul_ferry":
            return "ferry.fill"
        case "tokyo_rain", "rain_window":
            return "cloud.rain.fill"
        case "night_cafe":
            return "cup.and.saucer.fill"
        case "minka_library":
            return "books.vertical.fill"
        case "kyoto_bamboo":
            return "leaf.fill"
        case "temple_bell":
            return "bell.fill"
        case "night_forest":
            return "tree.fill"
        default:
            return "waveform"
        }
    }

    static let library: [Sound] = [
        Sound(id: "tokyo_metro", localizationKey: "snd_tokyo_metro", fileName: "tokyo_metro", context: .commute, region: .JP, isFree: false, defaultVolume: 0.7),
        Sound(id: "shinkansen", localizationKey: "snd_shinkansen", fileName: "shinkansen", context: .commute, region: .JP, isFree: false, defaultVolume: 0.7),
        Sound(id: "paris_metro", localizationKey: "snd_paris_metro", fileName: "paris_metro", context: .commute, region: .FR, isFree: false, defaultVolume: 0.7),
        Sound(id: "istanbul_ferry", localizationKey: "snd_istanbul_ferry", fileName: "istanbul_ferry", context: .commute, region: .TR, isFree: false, defaultVolume: 0.65),
        Sound(id: "tokyo_rain", localizationKey: "snd_tokyo_rain", fileName: "tokyo_rain", context: .focus, region: .JP, isFree: true, defaultVolume: 0.6),
        Sound(id: "deep_train", localizationKey: "snd_deep_train", fileName: "deep_train", context: .focus, region: .URBAN, isFree: true, defaultVolume: 0.55),
        Sound(id: "night_cafe", localizationKey: "snd_night_cafe", fileName: "night_cafe", context: .focus, region: .URBAN, isFree: false, defaultVolume: 0.5),
        Sound(id: "minka_library", localizationKey: "snd_minka_library", fileName: "minka_library", context: .focus, region: .JP, isFree: false, defaultVolume: 0.45),
        Sound(id: "kyoto_bamboo", localizationKey: "snd_kyoto_bamboo", fileName: "kyoto_bamboo", context: .reset, region: .JP, isFree: false, defaultVolume: 0.55),
        Sound(id: "temple_bell", localizationKey: "snd_temple_bell", fileName: "temple_bell", context: .reset, region: .JP, isFree: false, defaultVolume: 0.5),
        Sound(id: "rain_window", localizationKey: "snd_rain_window", fileName: "rain_window", context: .reset, region: .NATURE, isFree: true, defaultVolume: 0.6),
        Sound(id: "night_forest", localizationKey: "snd_night_forest", fileName: "night_forest", context: .sleep, region: .NATURE, isFree: false, defaultVolume: 0.4)
    ]

    static var freeLibrary: [Sound] { library.filter(\.isFree) }

    static func sounds(for context: AppContext) -> [Sound] {
        switch context {
        case .walking:
            return library.filter { $0.context == .reset || $0.context == .walking }
        case .deepWork:
            return library.filter { $0.context == .focus || $0.id == "deep_train" }
        case .unknown:
            return library
        default:
            return library.filter { $0.context == context }
        }
    }

    static func find(_ id: String) -> Sound? {
        library.first { $0.id == id }
    }
}

enum SoundLibrary {
    static let all = Sound.library
    static let freeIDs = Set(Sound.freeLibrary.map(\.id))
    static func sound(id: String) -> Sound? { Sound.find(id) }
    static func sounds(for context: AppContext) -> [Sound] { Sound.sounds(for: context) }
}
