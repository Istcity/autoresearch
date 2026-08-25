import CoreHaptics
import Foundation

@MainActor
final class HapticBreathingEngine {
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private var loopTask: Task<Void, Never>?
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
            loopTask = Task { [weak self] in
                while let engine = self, engine.isRunning, !Task.isCancelled {
                    await engine.playBoxCycle()
                }
            }
        } catch {
            isRunning = false
        }
    }

    func stop() {
        isRunning = false
        loopTask?.cancel()
        try? player?.stop(atTime: CHHapticTimeImmediate)
        engine?.stop()
        engine = nil
    }

    /// Box breathing 4-4-4-4: 3 short buzz inhale, silence hold, 1 long buzz exhale, silence wait.
    private func playBoxCycle() async {
        playEvents(count: 3, duration: 0.12, interval: 0.18, intensity: 0.8)
        try? await Task.sleep(for: .seconds(4))
        playEvents(count: 1, duration: 0.9, interval: 0, intensity: 0.55)
        try? await Task.sleep(for: .seconds(4))
        try? await Task.sleep(for: .seconds(4))
    }

    private func playEvents(count: Int, duration: TimeInterval, interval: TimeInterval, intensity: Float) {
        var events: [CHHapticEvent] = []
        var time: TimeInterval = 0
        for _ in 0..<count {
            events.append(
                CHHapticEvent(
                    eventType: .hapticContinuous,
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
