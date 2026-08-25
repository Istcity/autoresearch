import Foundation

struct Sound: Identifiable, Hashable, Codable, Sendable {
    let id: String
    let localizationKey: String
    let fileName: String
    let context: AppContext
    let isFree: Bool
    let defaultVolume: Float

    var bundleResource: String { fileName }
}

enum SoundLibrary {
    static let all: [Sound] = [
        Sound(id: "tokyo_metro", localizationKey: "sound_tokyo_metro", fileName: "tokyo_metro", context: .commute, isFree: false, defaultVolume: 0.7),
        Sound(id: "shinkansen", localizationKey: "sound_shinkansen", fileName: "shinkansen", context: .commute, isFree: false, defaultVolume: 0.7),
        Sound(id: "paris_metro", localizationKey: "sound_paris_metro", fileName: "paris_metro", context: .commute, isFree: false, defaultVolume: 0.7),
        Sound(id: "istanbul_ferry", localizationKey: "sound_istanbul_ferry", fileName: "istanbul_ferry", context: .commute, isFree: false, defaultVolume: 0.65),
        Sound(id: "tokyo_rain", localizationKey: "sound_tokyo_rain", fileName: "tokyo_rain", context: .focus, isFree: true, defaultVolume: 0.6),
        Sound(id: "deep_train", localizationKey: "sound_deep_train", fileName: "deep_train", context: .focus, isFree: true, defaultVolume: 0.55),
        Sound(id: "night_cafe", localizationKey: "sound_night_cafe", fileName: "night_cafe", context: .focus, isFree: false, defaultVolume: 0.5),
        Sound(id: "minka_library", localizationKey: "sound_minka_library", fileName: "minka_library", context: .focus, isFree: false, defaultVolume: 0.45),
        Sound(id: "kyoto_bamboo", localizationKey: "sound_kyoto_bamboo", fileName: "kyoto_bamboo", context: .reset, isFree: false, defaultVolume: 0.55),
        Sound(id: "temple_bell", localizationKey: "sound_temple_bell", fileName: "temple_bell", context: .reset, isFree: false, defaultVolume: 0.5),
        Sound(id: "rain_window", localizationKey: "sound_rain_window", fileName: "rain_window", context: .reset, isFree: true, defaultVolume: 0.6),
        Sound(id: "night_forest", localizationKey: "sound_night_forest", fileName: "night_forest", context: .sleep, isFree: false, defaultVolume: 0.4)
    ]

    static let freeIDs: Set<String> = ["tokyo_rain", "deep_train", "rain_window"]

    static func sound(id: String) -> Sound? {
        all.first { $0.id == id }
    }

    static func sounds(for context: AppContext) -> [Sound] {
        all.filter { $0.context == context || (context == .sleep && $0.id == "night_forest") || (context == .walking && $0.context == .reset) }
    }
}
