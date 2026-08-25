import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class AudioEngine {
    private let engine = AVAudioEngine()
    private let masterMixer = AVAudioMixerNode()
    private let channelA = AVAudioMixerNode()
    private let channelB = AVAudioMixerNode()
    private let playerA = AVAudioPlayerNode()
    private let playerB = AVAudioPlayerNode()

    private(set) var isPlaying = false
    private(set) var headphonesConnected = false
    var primaryVolume: Float = 0.7 {
        didSet { channelA.outputVolume = primaryVolume * journeyVolumeScale }
    }
    var secondaryVolume: Float = 0 {
        didSet { channelB.outputVolume = secondaryVolume }
    }
    var primarySound: Sound = SoundLibrary.sound(id: "tokyo_rain")!
    var secondarySound: Sound?

    private var journeyVolumeScale: Float = 1
    private var fadeTask: Task<Void, Never>?
    private var sessionStart: Date?
    private var sessionDuration: TimeInterval = 30 * 60
    private var untilArrival = false
    private var routeObserver: NSObjectProtocol?

    init() {
        attachGraph()
        observeRouteChanges()
        refreshHeadphones()
    }

    deinit {
        if let routeObserver {
            NotificationCenter.default.removeObserver(routeObserver)
        }
    }

    func play(sound: Sound, secondary: Sound? = nil, fadeDuration: TimeInterval = 1.2) {
        primarySound = sound
        secondarySound = secondary
        schedule(player: playerA, sound: sound)
        if let secondary {
            schedule(player: playerB, sound: secondary)
        }
        startEngineIfNeeded()
        playerA.play()
        if secondary != nil { playerB.play() }
        isPlaying = true
        sessionStart = Date()
        fade(to: primaryVolume, on: channelA, duration: fadeDuration)
        HapticEngine.success()
    }

    func stop(fadeDuration: TimeInterval = 1.0) {
        fadeTask?.cancel()
        fadeTask = Task { [weak self] in
            guard let self else { return }
            await self.fadeAsync(to: 0, on: self.channelA, duration: fadeDuration)
            await self.fadeAsync(to: 0, on: self.channelB, duration: fadeDuration)
            self.playerA.stop()
            self.playerB.stop()
            self.isPlaying = false
            self.sessionStart = nil
            HapticEngine.soft()
        }
    }

    func toggle() {
        if isPlaying {
            stop()
        } else {
            play(sound: primarySound, secondary: secondarySound)
        }
    }

    func setTimer(minutes: Int?) {
        if let minutes {
            untilArrival = false
            sessionDuration = TimeInterval(minutes * 60)
        } else {
            untilArrival = true
            sessionDuration = 45 * 60
        }
    }

    func updateJourneyArc() {
        guard isPlaying, let sessionStart, !untilArrival else {
            journeyVolumeScale = 1
            channelA.outputVolume = primaryVolume
            return
        }
        let elapsed = Date().timeIntervalSince(sessionStart)
        let progress = min(1, elapsed / sessionDuration)
        if progress < 0.15 {
            journeyVolumeScale = 0.65
        } else if progress < 0.85 {
            journeyVolumeScale = 1.0
        } else {
            let tail = (progress - 0.85) / 0.15
            journeyVolumeScale = Float(1.0 - tail)
            if progress >= 1 {
                stop(fadeDuration: 2.0)
            }
        }
        channelA.outputVolume = primaryVolume * journeyVolumeScale
    }

    var remainingSeconds: Int {
        guard isPlaying, let sessionStart else { return Int(sessionDuration) }
        return max(0, Int(sessionDuration - Date().timeIntervalSince(sessionStart)))
    }

    private func attachGraph() {
        engine.attach(playerA)
        engine.attach(playerB)
        engine.attach(channelA)
        engine.attach(channelB)
        engine.attach(masterMixer)

        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(playerA, to: channelA, format: format)
        engine.connect(playerB, to: channelB, format: format)
        engine.connect(channelA, to: masterMixer, format: format)
        engine.connect(channelB, to: masterMixer, format: format)
        engine.connect(masterMixer, to: engine.mainMixerNode, format: format)
        channelA.outputVolume = primaryVolume
        channelB.outputVolume = 0
        masterMixer.outputVolume = 1
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Stillway audio engine failed: \(error)")
        }
    }

    private func schedule(player: AVAudioPlayerNode, sound: Sound) {
        player.stop()
        player.reset()
        let buffer = loadBuffer(for: sound) ?? Self.makeProceduralBuffer(for: sound)
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func loadBuffer(for sound: Sound) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a") else {
            return nil
        }
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        let frameCount = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
            return nil
        }
        try? file.read(into: buffer)
        return buffer
    }

    /// Placeholder ambient loop so the app is playable before field recordings ship.
    private static func makeProceduralBuffer(for sound: Sound) -> AVAudioPCMBuffer {
        let sampleRate: Double = 44_100
        let seconds: Double = 8
        let frames = AVAudioFrameCount(sampleRate * seconds)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        let seed = UInt64(sound.id.utf8.reduce(0) { $0 &+ UInt64($1) })
        var rng = SplitMix64(seed: seed)
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        var pink: [Double] = Array(repeating: 0, count: 7)
        let brightness: Double = {
            switch sound.context {
            case .commute: return 0.55
            case .focus: return 0.35
            case .sleep: return 0.18
            case .reset: return 0.42
            case .walking: return 0.5
            case .deepwork: return 0.28
            case .unknown: return 0.3
            }
        }()
        for i in 0..<Int(frames) {
            var white = rng.nextNormalized()
            pink[0] = 0.99886 * pink[0] + white * 0.0555179
            pink[1] = 0.99332 * pink[1] + white * 0.0750759
            pink[2] = 0.96900 * pink[2] + white * 0.1538520
            pink[3] = 0.86650 * pink[3] + white * 0.3104856
            pink[4] = 0.55000 * pink[4] + white * 0.5329522
            pink[5] = -0.7616 * pink[5] - white * 0.0168980
            let sample = pink.reduce(0, +) + white * 0.5362 + pink[6] * 0.115926
            pink[6] = white * 0.5362
            let t = Double(i) / sampleRate
            let drift = sin(t * brightness * 0.7) * 0.08
            let value = Float(max(-1, min(1, sample * 0.08 * (0.85 + drift))))
            left[i] = value
            right[i] = value * 0.96
            _ = white
        }
        return buffer
    }

    private func fade(to volume: Float, on node: AVAudioMixerNode, duration: TimeInterval) {
        fadeTask?.cancel()
        fadeTask = Task { await fadeAsync(to: volume, on: node, duration: duration) }
    }

    private func fadeAsync(to volume: Float, on node: AVAudioMixerNode, duration: TimeInterval) async {
        let steps = 60
        let start = node.outputVolume
        let stepTime = duration / Double(steps)
        for i in 1...steps {
            if Task.isCancelled { return }
            let t = Float(i) / Float(steps)
            node.outputVolume = start + (volume - start) * t
            try? await Task.sleep(for: .seconds(stepTime))
        }
    }

    private func observeRouteChanges() {
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleRouteChange(notification)
            }
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        refreshHeadphones()
        guard let info = notification.userInfo,
              let raw = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: raw) else { return }
        if reason == .oldDeviceUnavailable, isPlaying {
            stop(fadeDuration: 0.5)
        }
        NotificationCenter.default.post(name: .stillwayHeadphonesChanged, object: headphonesConnected)
    }

    private func refreshHeadphones() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        headphonesConnected = outputs.contains { output in
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains(output.portType)
        }
    }
}

extension Notification.Name {
    static let stillwayHeadphonesChanged = Notification.Name("stillwayHeadphonesChanged")
}

private struct SplitMix64 {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    mutating func nextNormalized() -> Double {
        Double(next() >> 11) / Double(1 << 53) * 2 - 1
    }
}
