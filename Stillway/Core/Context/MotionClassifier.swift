import Foundation
import CoreMotion
import Observation

@Observable
@MainActor
final class MotionClassifier {
    var latestActivity: CMMotionActivity?
    var trainProbability: Double = 0
    var isPhoneHorizontal = false

    private let activityManager = CMMotionActivityManager()
    private let motion = CMMotionManager()
    private var timer: Timer?

    func start() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self, let activity else { return }
            self.latestActivity = activity
            if activity.automotive {
                self.trainProbability = max(self.trainProbability, 0.4)
            }
        }
        motion.accelerometerUpdateInterval = 1.0
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let z = data?.acceleration.z else { return }
            self?.isPhoneHorizontal = abs(z) > 0.85
        }
    }

    func stop() {
        activityManager.stopActivityUpdates()
        motion.stopAccelerometerUpdates()
        timer?.invalidate()
    }

    /// Placeholder until TrainClassifier.mlmodel is trained with Create ML.
    func ingestCoreMLProbability(_ value: Double) {
        trainProbability = value
    }
}
