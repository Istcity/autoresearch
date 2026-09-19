import Foundation
import CoreMotion
import Observation

enum ActivityState: String, Sendable {
    case stationary
    case walking
    case running
    case automotive
    case cycling
    case unknown

    init(from activity: CMMotionActivity?) {
        guard let activity else {
            self = .unknown
            return
        }
        if activity.automotive { self = .automotive }
        else if activity.cycling { self = .cycling }
        else if activity.running { self = .running }
        else if activity.walking { self = .walking }
        else if activity.stationary { self = .stationary }
        else { self = .unknown }
    }

    var isTransit: Bool { self == .automotive || self == .cycling }
    var isStationary: Bool { self == .stationary }

    var motionActivity: CMMotionActivity? { nil }
}

@Observable
@MainActor
final class MotionClassifier {
    var currentActivity: ActivityState = .unknown
    var isPhoneHorizontal = false
    var latestActivity: CMMotionActivity?
    /// 0...1 likelihood the user is on rail/metro transit (heuristic until Core ML ships).
    var trainProbability: Double = 0

    private let activityManager = CMMotionActivityManager()
    private let motion = CMMotionManager()
    private let trainClassifier = TrainHeuristicClassifier()

    func start() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self else { return }
            self.latestActivity = activity
            self.currentActivity = ActivityState(from: activity)
            self.trainClassifier.ingest(activity: activity, accelerationZ: nil)
            self.trainProbability = max(self.trainProbability, self.trainClassifier.probability)
            if activity?.automotive == true {
                self.trainProbability = max(self.trainProbability, 0.45)
            }
        }
        motion.accelerometerUpdateInterval = 2
        motion.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let z = data.acceleration.z
            self.isPhoneHorizontal = abs(z) > 0.85
            self.trainClassifier.ingest(activity: self.latestActivity, accelerationZ: z)
            self.trainProbability = self.trainClassifier.probability
        }
    }

    func stop() {
        activityManager.stopActivityUpdates()
        motion.stopAccelerometerUpdates()
    }

    func ingestCoreMLProbability(_ value: Double) {
        trainProbability = min(1, max(trainProbability, value))
    }
}
