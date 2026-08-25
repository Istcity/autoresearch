import Foundation
import CoreLocation
import CoreMotion
import SwiftData

@MainActor
final class SleepDetector {
    var onSleepPrompt: (() -> Void)?

    func checkSleepConditions(
        preferences: UserPreferences,
        places: [UserPlace],
        currentLocation: CLLocation?,
        motionActivity: CMMotionActivity?,
        isPhoneHorizontal: Bool
    ) {
        guard preferences.sleepModeEnabled else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= preferences.sleepStartHour || hour < preferences.sleepEndHour else { return }
        guard let home = places.first(where: { $0.label == .home }) else { return }
        guard let currentLocation, home.distance(to: currentLocation) < 150 else { return }
        guard motionActivity?.stationary == true else { return }
        guard isPhoneHorizontal else { return }
        onSleepPrompt?()
    }
}
