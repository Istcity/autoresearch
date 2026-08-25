import Foundation
import CoreLocation
import CoreMotion
import SwiftData

@MainActor
final class SleepDetector {
    private var preferences: UserPreferences?
    private var homePlace: UserPlace?
    private var timer: Timer?
    private weak var motion: MotionClassifier?
    private weak var location: LocationManager?

    var onSleepPrompt: (() -> Void)?

    func configure(preferences: UserPreferences, homePlace: UserPlace?) {
        self.preferences = preferences
        self.homePlace = homePlace
    }

    func startMonitoring(motion: MotionClassifier? = nil, location: LocationManager? = nil) {
        self.motion = motion
        self.location = location
        stopMonitoring()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.evaluate()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func checkSleepConditions(
        preferences: UserPreferences,
        places: [UserPlace],
        currentLocation: CLLocation?,
        motionActivity: CMMotionActivity?,
        isPhoneHorizontal: Bool
    ) {
        configure(preferences: preferences, homePlace: places.first(where: { $0.label == .home }))
        evaluate(
            currentLocation: currentLocation,
            isStationary: motionActivity?.stationary == true,
            isPhoneHorizontal: isPhoneHorizontal
        )
    }

    private func evaluate() {
        evaluate(
            currentLocation: location?.currentLocation,
            isStationary: motion?.currentActivity.isStationary == true,
            isPhoneHorizontal: motion?.isPhoneHorizontal == true
        )
    }

    private func evaluate(currentLocation: CLLocation?, isStationary: Bool, isPhoneHorizontal: Bool) {
        guard let preferences, preferences.sleepModeEnabled else { return }
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= preferences.sleepStartHour || hour < preferences.sleepEndHour else { return }
        guard let home = homePlace, let currentLocation, home.distance(to: currentLocation) < 200 else { return }
        guard isStationary, isPhoneHorizontal else { return }
        NotificationCenter.default.post(name: .sleepPromptNeeded, object: nil)
        onSleepPrompt?()
    }
}
