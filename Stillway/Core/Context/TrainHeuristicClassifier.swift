import Foundation
import CoreMotion

/// On-device heuristic stand-in for TrainClassifier.mlmodel.
/// Combines automotive activity persistence + accelerometer steadiness into a transit-rail score.
@MainActor
final class TrainHeuristicClassifier {
    private(set) var probability: Double = 0
    private var automotiveTicks = 0
    private var sampleCount = 0
    private var steadyTicks = 0

    func ingest(activity: CMMotionActivity?, accelerationZ: Double?) {
        sampleCount += 1
        if activity?.automotive == true {
            automotiveTicks = min(automotiveTicks + 1, 40)
        } else {
            automotiveTicks = max(automotiveTicks - 1, 0)
        }
        if let z = accelerationZ, abs(z) < 0.35 {
            // Phone roughly upright in a bag/pocket — common on trains.
            steadyTicks = min(steadyTicks + 1, 40)
        } else {
            steadyTicks = max(steadyTicks - 1, 0)
        }
        let autoScore = Double(automotiveTicks) / 40.0
        let steadyScore = Double(steadyTicks) / 40.0
        probability = min(1, autoScore * 0.7 + steadyScore * 0.3)
    }

    func reset() {
        probability = 0
        automotiveTicks = 0
        steadyTicks = 0
        sampleCount = 0
    }
}
