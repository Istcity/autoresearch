import Foundation
import SwiftData
import CoreLocation

enum PlaceLabel: String, Codable, CaseIterable, Identifiable, Sendable {
    case home
    case work
    case library
    case cafe
    case gym
    case other

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .home: return "place_home"
        case .work: return "place_work"
        case .library: return "place_library"
        case .cafe: return "place_cafe"
        case .gym: return "place_gym"
        case .other: return "place_other"
        }
    }

    var symbolName: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .library: return "book.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .gym: return "figure.strengthtraining.traditional"
        case .other: return "star.fill"
        }
    }

    var suggestedContext: AppContext {
        switch self {
        case .home: return .reset
        case .work, .library: return .focus
        case .cafe: return .focus
        case .gym: return .reset
        case .other: return .unknown
        }
    }
}

@Model
final class UserPlace {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var labelRaw: String?
    var visitCount: Int
    var lastSeen: Date
    var firstSeen: Date
    var autoStartEnabled: Bool
    var defaultSoundID: String?
    var homeConfidence: Double
    var customName: String?

    var label: PlaceLabel? {
        get { labelRaw.flatMap(PlaceLabel.init(rawValue:)) }
        set { labelRaw = newValue?.rawValue }
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        label: PlaceLabel? = nil,
        visitCount: Int = 1,
        lastSeen: Date = .now,
        firstSeen: Date = .now,
        autoStartEnabled: Bool = false,
        defaultSoundID: String? = nil,
        homeConfidence: Double = 0,
        customName: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.labelRaw = label?.rawValue
        self.visitCount = visitCount
        self.lastSeen = lastSeen
        self.firstSeen = firstSeen
        self.autoStartEnabled = autoStartEnabled
        self.defaultSoundID = defaultSoundID
        self.homeConfidence = homeConfidence
        self.customName = customName
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: location)
    }
}

@Model
final class CommuteSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var contextRaw: String
    var soundID: String
    var triggerRaw: String
    var stationID: String?

    var context: AppContext {
        get { AppContext(rawValue: contextRaw) ?? .unknown }
        set { contextRaw = newValue.rawValue }
    }

    var trigger: TriggerType {
        get { TriggerType(rawValue: triggerRaw) ?? .manual }
        set { triggerRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        endedAt: Date? = nil,
        context: AppContext,
        soundID: String,
        trigger: TriggerType,
        stationID: String? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.contextRaw = context.rawValue
        self.soundID = soundID
        self.triggerRaw = trigger.rawValue
        self.stationID = stationID
    }
}

@Model
final class UserPreferences {
    @Attribute(.unique) var id: UUID
    var hasCompletedOnboarding: Bool
    var contextDetectionEnabled: Bool
    var sleepModeEnabled: Bool
    var sleepStartHour: Int
    var sleepEndHour: Int
    var hapticBreathingEnabled: Bool
    var selectedLanguage: String
    var lastSoundID: String
    var lastTimerMinutes: Int
    var selectedContextRaw: String

    var selectedContext: AppContext {
        get { AppContext(rawValue: selectedContextRaw) ?? .unknown }
        set { selectedContextRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        contextDetectionEnabled: Bool = true,
        sleepModeEnabled: Bool = true,
        sleepStartHour: Int = 22,
        sleepEndHour: Int = 7,
        hapticBreathingEnabled: Bool = false,
        selectedLanguage: String = LanguageCode.autoDetect().rawValue,
        lastSoundID: String = "tokyo_rain",
        lastTimerMinutes: Int = 30,
        selectedContext: AppContext = .unknown
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.contextDetectionEnabled = contextDetectionEnabled
        self.sleepModeEnabled = sleepModeEnabled
        self.sleepStartHour = sleepStartHour
        self.sleepEndHour = sleepEndHour
        self.hapticBreathingEnabled = hapticBreathingEnabled
        self.selectedLanguage = selectedLanguage
        self.lastSoundID = lastSoundID
        self.lastTimerMinutes = lastTimerMinutes
        self.selectedContextRaw = selectedContext.rawValue
    }
}
