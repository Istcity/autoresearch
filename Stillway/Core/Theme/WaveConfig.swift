import Foundation

struct WaveConfig: Equatable, Sendable {
    let layerCount: Int
    let frequency: Double
    let amplitude: Double
    let phaseSpeed: Double
    let opacity: Double

    static func config(for context: AppContext) -> WaveConfig {
        switch context {
        case .commute:
            return WaveConfig(layerCount: 3, frequency: 0.55, amplitude: 22, phaseSpeed: 0.55, opacity: 0.70)
        case .focus:
            return WaveConfig(layerCount: 3, frequency: 0.35, amplitude: 18, phaseSpeed: 0.35, opacity: 0.62)
        case .sleep:
            return WaveConfig(layerCount: 2, frequency: 0.18, amplitude: 14, phaseSpeed: 0.22, opacity: 0.55)
        case .reset:
            return WaveConfig(layerCount: 3, frequency: 0.42, amplitude: 20, phaseSpeed: 0.42, opacity: 0.65)
        case .walking:
            return WaveConfig(layerCount: 3, frequency: 0.48, amplitude: 17, phaseSpeed: 0.48, opacity: 0.62)
        case .deepWork:
            return WaveConfig(layerCount: 3, frequency: 0.50, amplitude: 24, phaseSpeed: 0.50, opacity: 0.72)
        case .unknown:
            return WaveConfig(layerCount: 2, frequency: 0.28, amplitude: 12, phaseSpeed: 0.28, opacity: 0.45)
        }
    }

    static func `for`(_ context: AppContext) -> WaveConfig {
        config(for: context)
    }

    static let collapsed = WaveConfig(layerCount: 2, frequency: 0.2, amplitude: 0, phaseSpeed: 0.12, opacity: 0)
}
