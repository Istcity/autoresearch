import AVFoundation
import Foundation
import Observation

enum JourneyPhase: String, Sendable {
    case idle
    case arrival
    case deepZone
    case slowReset
}

@Observable
@MainActor
final class AudioEngine {
    private let engine = AVAudioEngine()
    private let masterMixer = AVAudioMixerNode()
    private let primaryMixer = AVAudioMixerNode()
    private let secondaryMixer = AVAudioMixerNode()
    private let primaryPlayer = AVAudioPlayerNode()
    private let secondaryPlayer = AVAudioPlayerNode()

    private(set) var isPlaying = false
    var primarySound: Sound?
    var secondarySound: Sound?
    var journeyPhase: JourneyPhase = .idle

    var primaryVolume: Float = 0.8 {
        didSet { primaryMixer.outputVolume = primaryVolume }
    }
    var secondaryVolume: Float = 0.5 {
        didSet { secondaryMixer.outputVolume = secondaryVolume }
    }

    var isHeadphonesConnected: Bool { headphonesConnected }
    private(set) var headphonesConnected = false

    private var fadeTask: Task<Void, Never>?
    private var journeyTask: Task<Void, Never>?
    private var sessionStart: Date?
    private var sessionDuration: TimeInterval = 30 * 60
    private var untilArrival = false
    private var routeObserver: NSObjectProtocol?
    private var interruptionObserver: NSObjectProtocol?

    init() {
        attachGraph()
        observeRouteChanges()
        observeInterruptions()
        refreshHeadphones()
    }

    func play(sound: Sound, fadeDuration: Double = 1.5) {
        primarySound = sound
        schedule(player: primaryPlayer, sound: sound)
        startEngineIfNeeded()
        primaryPlayer.play()
        isPlaying = true
        sessionStart = Date()
        journeyPhase = .arrival
        fadeTask?.cancel()
        fadeTask = Task { await fadeAsync(to: primaryVolume, on: primaryMixer, duration: fadeDuration) }
        HapticEngine.success()
    }

    func playSecondary(sound: Sound) {
        secondarySound = sound
        schedule(player: secondaryPlayer, sound: sound)
        startEngineIfNeeded()
        secondaryPlayer.play()
        secondaryMixer.outputVolume = secondaryVolume
    }

    func stopSecondary() {
        secondaryPlayer.stop()
        secondarySound = nil
        secondaryMixer.outputVolume = 0
    }

    func stop(fadeDuration: Double = 2.0) {
        journeyTask?.cancel()
        fadeTask?.cancel()
        fadeTask = Task { [weak self] in
            guard let self else { return }
            await self.fadeAsync(to: 0, on: self.primaryMixer, duration: fadeDuration)
            await self.fadeAsync(to: 0, on: self.secondaryMixer, duration: fadeDuration)
            self.primaryPlayer.stop()
            self.secondaryPlayer.stop()
            self.isPlaying = false
            self.sessionStart = nil
            self.journeyPhase = .idle
            HapticEngine.soft()
        }
    }

    func toggle() {
        if isPlaying {
            stop()
        } else if let sound = primarySound ?? Sound.find("tokyo_rain") {
            play(sound: sound)
        }
    }

    func startJourneyArc(minutes: Double) {
        untilArrival = false
        sessionDuration = minutes * 60
        sessionStart = Date()
        journeyTask?.cancel()
        journeyTask = Task { [weak self] in
            while let self, self.isPlaying, !Task.isCancelled {
                self.updateJourneyArc()
                try? await Task.sleep(for: .seconds(1))
            }
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

    func setMasterVolume(_ vol: Float, duration: Double) {
        fadeTask?.cancel()
        fadeTask = Task { await fadeAsync(to: vol, on: masterMixer, duration: duration) }
    }

    func updateJourneyArc() {
        guard isPlaying, let sessionStart, !untilArrival else { return }
        let elapsed = Date().timeIntervalSince(sessionStart)
        let progress = min(1, elapsed / sessionDuration)
        if progress < 0.15 {
            journeyPhase = .arrival
            masterMixer.outputVolume = 0.65
        } else if progress < 0.85 {
            journeyPhase = .deepZone
            masterMixer.outputVolume = 1.0
        } else {
            journeyPhase = .slowReset
            let tail = Float((progress - 0.85) / 0.15)
            masterMixer.outputVolume = max(0.3, 1.0 - tail * 0.7)
            if progress >= 1 {
                stop(fadeDuration: 2.0)
            }
        }
    }

    var remainingSeconds: Int {
        guard isPlaying, let sessionStart else { return Int(sessionDuration) }
        return max(0, Int(sessionDuration - Date().timeIntervalSince(sessionStart)))
    }

    private func attachGraph() {
        engine.attach(primaryPlayer)
        engine.attach(secondaryPlayer)
        engine.attach(primaryMixer)
        engine.attach(secondaryMixer)
        engine.attach(masterMixer)
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(primaryPlayer, to: primaryMixer, format: format)
        engine.connect(secondaryPlayer, to: secondaryMixer, format: format)
        engine.connect(primaryMixer, to: masterMixer, format: format)
        engine.connect(secondaryMixer, to: masterMixer, format: format)
        engine.connect(masterMixer, to: engine.mainMixerNode, format: format)
        primaryMixer.outputVolume = primaryVolume
        secondaryMixer.outputVolume = 0
        masterMixer.outputVolume = 1
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        try? engine.start()
    }

    private func schedule(player: AVAudioPlayerNode, sound: Sound) {
        player.stop()
        player.reset()
        let buffer = loadBuffer(for: sound) ?? Self.makeProceduralBuffer(for: sound)
        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func loadBuffer(for sound: Sound) -> AVAudioPCMBuffer? {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "m4a"),
              let file = try? AVAudioFile(forReading: url) else { return nil }
        let frames = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frames) else { return nil }
        try? file.read(into: buffer)
        return buffer
    }

    private static func makeProceduralBuffer(for sound: Sound) -> AVAudioPCMBuffer {
        let sampleRate: Double = 44_100
        let frames = AVAudioFrameCount(sampleRate * 8)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames)!
        buffer.frameLength = frames
        var rng = SplitMix64(seed: UInt64(sound.id.utf8.reduce(0) { $0 &+ UInt64($1) }))
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]
        var pink = Array(repeating: 0.0, count: 7)
        for i in 0..<Int(frames) {
            let white = rng.nextNormalized()
            pink[0] = 0.99886 * pink[0] + white * 0.0555179
            pink[1] = 0.99332 * pink[1] + white * 0.0750759
            pink[2] = 0.96900 * pink[2] + white * 0.1538520
            pink[3] = 0.86650 * pink[3] + white * 0.3104856
            pink[4] = 0.55000 * pink[4] + white * 0.5329522
            pink[5] = -0.7616 * pink[5] - white * 0.0168980
            let sample = pink.reduce(0, +) + white * 0.5362
            pink[6] = white * 0.5362
            let value = Float(max(-1, min(1, sample * 0.08)))
            left[i] = value
            right[i] = value * 0.96
        }
        return buffer
    }

    private func fadeAsync(to volume: Float, on node: AVAudioMixerNode, duration: TimeInterval) async {
        let steps = 60
        let start = node.outputVolume
        let stepTime = duration / Double(max(steps, 1))
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

    private func observeInterruptions() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleInterruption(notification)
            }
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        refreshHeadphones()
        guard let info = notification.userInfo,
              let raw = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: raw) else { return }
        switch reason {
        case .oldDeviceUnavailable:
            if isPlaying { stop(fadeDuration: 0.5) }
        case .newDeviceAvailable:
            if headphonesConnected {
                NotificationCenter.default.post(name: .headphonesConnected, object: nil)
            }
        default:
            break
        }
    }

    private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        if type == .ended {
            let options = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            if AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) {
                startEngineIfNeeded()
                if isPlaying { primaryPlayer.play() }
            }
        }
    }

    private func refreshHeadphones() {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        headphonesConnected = outputs.contains {
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains($0.portType)
        }
    }
}

extension Notification.Name {
    static let headphonesConnected = Notification.Name("stillway.headphonesConnected")
    static let contextDidChange = Notification.Name("stillway.contextDidChange")
    static let autoSessionTriggered = Notification.Name("stillway.autoSessionTriggered")
    static let placeNeedsLabel = Notification.Name("stillway.placeNeedsLabel")
    static let sleepPromptNeeded = Notification.Name("stillway.sleepPromptNeeded")
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
