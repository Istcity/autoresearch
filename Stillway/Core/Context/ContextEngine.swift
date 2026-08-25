import Foundation
import CoreLocation
import CoreMotion
import Observation
import SwiftData

struct ContextSignals {
    var geofenceStationID: String?
    var motionActivity: CMMotionActivity?
    var trainProbability: Double = 0
    var currentVisit: CLVisit?
    var nearestPlace: UserPlace?
    var headphonesConnected: Bool = false
    var currentHour: Int = Calendar.current.component(.hour, from: Date())
    var isPhoneHorizontal: Bool = false
}

struct ContextDecision: Equatable {
    var context: AppContext
    var shouldAutoStart: Bool
    var triggerType: TriggerType
    var suggestedSoundID: String
    var confidence: Double
}

@Observable
@MainActor
final class ContextEngine {
    var latestDecision = ContextDecision(
        context: .unknown,
        shouldAutoStart: false,
        triggerType: .manual,
        suggestedSoundID: "tokyo_rain",
        confidence: 0
    )
    var signals = ContextSignals()
    var lastStation: Station?

    func evaluate(signals: ContextSignals, preferences: UserPreferences, isPro: Bool) -> ContextDecision {
        self.signals = signals
        let hour = signals.currentHour

        if let stationID = signals.geofenceStationID, signals.trainProbability >= 0.45 || signals.motionActivity?.automotive == true {
            lastStation = lastStation
            return make(context: .commute, auto: isPro && signals.headphonesConnected, trigger: signals.headphonesConnected ? .automatic : .suggested, sound: "tokyo_metro", confidence: 0.92, stationHint: stationID)
        }

        if signals.motionActivity?.automotive == true {
            return make(context: .commute, auto: isPro && signals.headphonesConnected, trigger: signals.headphonesConnected ? .automatic : .suggested, sound: "shinkansen", confidence: 0.8)
        }

        if preferences.sleepModeEnabled,
           let place = signals.nearestPlace,
           place.label == .home,
           hour >= preferences.sleepStartHour || hour < preferences.sleepEndHour,
           signals.motionActivity?.stationary == true,
           signals.isPhoneHorizontal {
            return make(context: .sleep, auto: isPro && preferences.sleepModeEnabled, trigger: .suggested, sound: "night_forest", confidence: 0.78)
        }

        if let place = signals.nearestPlace, place.label == .work || place.label == .library, (9...18).contains(hour) {
            return make(context: .focus, auto: isPro && place.autoStartEnabled && signals.headphonesConnected, trigger: place.autoStartEnabled ? .automatic : .suggested, sound: place.defaultSoundID ?? "tokyo_rain", confidence: 0.74)
        }

        if signals.motionActivity?.walking == true {
            return make(context: .walking, auto: false, trigger: signals.headphonesConnected ? .suggested : .manual, sound: "kyoto_bamboo", confidence: 0.6)
        }

        if let place = signals.nearestPlace, place.label == .cafe {
            return make(context: .reset, auto: false, trigger: .suggested, sound: "night_cafe", confidence: 0.55)
        }

        return make(context: .unknown, auto: false, trigger: .manual, sound: preferences.lastSoundID, confidence: 0.2)
    }

    private func make(context: AppContext, auto: Bool, trigger: TriggerType, sound: String, confidence: Double, stationHint: String? = nil) -> ContextDecision {
        let decision = ContextDecision(
            context: context,
            shouldAutoStart: auto,
            triggerType: trigger,
            suggestedSoundID: sound,
            confidence: confidence
        )
        latestDecision = decision
        return decision
    }
}
