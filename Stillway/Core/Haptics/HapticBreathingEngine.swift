import CoreHaptics
import Foundation

@MainActor
final class HapticBreathingEngine {
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private(set) var isRunning = false

    var isSupported: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    func start() {
        guard isSupported else { return }
        stop()
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            isRunning = true
            playCycle()
        } catch {
            isRunning = false
        }
    }

    func stop() {
        isRunning = false
        try? player?.stop(atTime: CHHapticTimeImmediate)
        engine?.stop()
        engine = nil
    }

    /// Box breathing 4-4-4-4 on a 16s recursive loop.
    private func playCycle() {
        guard isRunning else { return }
        playEvents(count: 3, duration: 0.12, interval: 0.15, intensity: 0.85)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self, self.isRunning else { return }
            self.playEvents(count: 1, duration: 0.8, interval: 0, intensity: 0.55)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 16) { [weak self] in
            self?.playCycle()
        }
    }

    private func playEvents(count: Int, duration: TimeInterval, interval: TimeInterval, intensity: Float) {
        var events: [CHHapticEvent] = []
        var time: TimeInterval = 0
        for _ in 0..<count {
            events.append(
                CHHapticEvent(
                    eventType: count == 1 ? .hapticContinuous : .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                    ],
                    relativeTime: time,
                    duration: duration
                )
            )
            time += duration + interval
        }
        guard let pattern = try? CHHapticPattern(events: events, parameters: []) else { return }
        player = try? engine?.makeAdvancedPlayer(with: pattern)
        try? player?.start(atTime: CHHapticTimeImmediate)
    }
}
