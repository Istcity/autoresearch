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
            return WaveConfig(layerCount: 4, frequency: 0.9, amplitude: 32, phaseSpeed: 1.8, opacity: 0.85)
        case .focus:
            return WaveConfig(layerCount: 3, frequency: 0.5, amplitude: 24, phaseSpeed: 0.9, opacity: 0.75)
        case .sleep:
            return WaveConfig(layerCount: 3, frequency: 0.25, amplitude: 18, phaseSpeed: 0.5, opacity: 0.65)
        case .reset:
            return WaveConfig(layerCount: 4, frequency: 0.7, amplitude: 28, phaseSpeed: 1.2, opacity: 0.80)
        case .walking:
            return WaveConfig(layerCount: 3, frequency: 1.1, amplitude: 22, phaseSpeed: 2.0, opacity: 0.75)
        case .deepWork:
            return WaveConfig(layerCount: 4, frequency: 1.3, amplitude: 36, phaseSpeed: 2.2, opacity: 0.90)
        case .unknown:
            return WaveConfig(layerCount: 2, frequency: 0.4, amplitude: 16, phaseSpeed: 0.6, opacity: 0.50)
        }
    }

    static func `for`(_ context: AppContext) -> WaveConfig {
        config(for: context)
    }

    static let collapsed = WaveConfig(layerCount: 2, frequency: 0.3, amplitude: 0, phaseSpeed: 0.2, opacity: 0)
}
