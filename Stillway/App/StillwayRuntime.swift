import Foundation
import Observation
import SwiftData
import CoreLocation

@Observable
@MainActor
final class StillwayRuntime {
    let theme = ThemeEngine()
    let localization = LocalizationManager()
    let audio = AudioEngine()
    let location = LocationManager()
    let geofence = GeofenceManager()
    let stations = StationDatabase.loadFromBundle()
    let contextEngine = ContextEngine()
    let visitTracker = VisitTracker()
    let motion = MotionClassifier()
    let sleepDetector = SleepDetector()
    let breathing = HapticBreathingEngine()
    let liveActivity = LiveActivityManager()
    let store = PurchaseManager()

    lazy var transition = ContextTransitionEngine(theme: theme)

    var selectedTimerMinutes: Int? = 30
    var showSettings = false
    var showPlaces = false
    var showSounds = false
    var showPlaceLabel = false
    var toast: String?
    var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "stillway.onboarded")

    private var tickTask: Task<Void, Never>?

    func startServices(modelContext: ModelContext) {
        location.onVisit = { [weak self] visit in
            self?.handleVisit(visit, modelContext: modelContext)
        }
        location.onSignificantChange = { [weak self] location in
            self?.handleLocation(location, modelContext: modelContext)
        }
        geofence.onEnter = { [weak self] station in
            self?.handleStationEnter(station, modelContext: modelContext)
        }
        sleepDetector.onSleepPrompt = { [weak self] in
            self?.toast = self?.localization.string("notif_sleep")
        }
        motion.start()
        location.start()
        Task { await store.load() }
        startTicker()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "stillway.onboarded")
        location.requestAlways()
    }

    func handleStartStop(preferences: UserPreferences?) {
        if audio.isPlaying {
            audio.stop()
            liveActivity.end()
            breathing.stop()
            toast = localization.string("toast_stopped")
        } else {
            let sound = SoundLibrary.sound(id: preferences?.lastSoundID ?? audio.primarySound.id) ?? audio.primarySound
            audio.setTimer(minutes: selectedTimerMinutes)
            audio.play(sound: sound)
            theme.apply(sound.context == .unknown ? theme.currentContext : sound.context)
            liveActivity.start(
                contextName: localization.string(theme.currentContext.localizationKey).uppercased(),
                soundName: localization.string(sound.localizationKey),
                remainingSeconds: audio.remainingSeconds,
                accentHex: "4169E1"
            )
            if store.isPro, preferences?.hapticBreathingEnabled == true {
                breathing.start()
            }
            toast = localization.string("toast_started")
            HapticEngine.tap()
        }
    }

    func selectSound(_ sound: Sound, isPro: Bool, preferences: UserPreferences?) {
        if !sound.isFree && !isPro {
            showSettings = true
            return
        }
        audio.primarySound = sound
        preferences?.lastSoundID = sound.id
        theme.apply(sound.context)
        if audio.isPlaying {
            audio.play(sound: sound, secondary: audio.secondarySound)
        }
        HapticEngine.select()
    }

    func selectTimer(_ minutes: Int?) {
        selectedTimerMinutes = minutes
        audio.setTimer(minutes: minutes)
        HapticEngine.select()
    }

    private func startTicker() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.audio.updateJourneyArc()
                self?.publishWidgetState()
                if let self, self.audio.isPlaying {
                    self.liveActivity.update(
                        contextName: self.localization.string(self.theme.displayedContext.localizationKey).uppercased(),
                        soundName: self.localization.string(self.audio.primarySound.localizationKey),
                        remainingSeconds: self.audio.remainingSeconds,
                        accentHex: "4169E1",
                        isPlaying: true
                    )
                }
            }
        }
    }

    private func handleVisit(_ visit: CLVisit, modelContext: ModelContext) {
        let places = (try? modelContext.fetch(FetchDescriptor<UserPlace>())) ?? []
        visitTracker.process(visit: visit, places: places, context: modelContext)
        if visitTracker.pendingLabelPlace != nil, store.isPro {
            showPlaceLabel = true
        }
        reevaluate(modelContext: modelContext)
    }

    private func handleLocation(_ location: CLLocation, modelContext: ModelContext) {
        let nearby = stations.nearest(to: location)
        geofence.refresh(around: location, stations: nearby)
        reevaluate(modelContext: modelContext)
    }

    private func handleStationEnter(_ station: Station, modelContext: ModelContext) {
        contextEngine.lastStation = station
        contextEngine.signals.geofenceStationID = station.id
        reevaluate(modelContext: modelContext)
    }

    private func reevaluate(modelContext: ModelContext) {
        let places = (try? modelContext.fetch(FetchDescriptor<UserPlace>())) ?? []
        let prefs = (try? modelContext.fetch(FetchDescriptor<UserPreferences>()))?.first
        let nearest = nearestPlace(places: places)
        var signals = contextEngine.signals
        signals.headphonesConnected = audio.headphonesConnected
        signals.motionActivity = motion.latestActivity
        signals.trainProbability = motion.trainProbability
        signals.isPhoneHorizontal = motion.isPhoneHorizontal
        signals.nearestPlace = nearest
        signals.currentHour = Calendar.current.component(.hour, from: Date())
        let preferences = prefs ?? UserPreferences()
        if prefs == nil { modelContext.insert(preferences) }
        guard preferences.contextDetectionEnabled else { return }
        let decision = contextEngine.evaluate(signals: signals, preferences: preferences, isPro: store.isPro)
        transition.sweep(to: decision.context)
        if decision.shouldAutoStart, !audio.isPlaying {
            if let sound = SoundLibrary.sound(id: decision.suggestedSoundID) {
                selectSound(sound, isPro: store.isPro, preferences: preferences)
                handleStartStop(preferences: preferences)
            }
        }
        if let currentLocation = location.currentLocation {
            sleepDetector.checkSleepConditions(
                preferences: preferences,
                places: places,
                currentLocation: currentLocation,
                motionActivity: motion.latestActivity,
                isPhoneHorizontal: motion.isPhoneHorizontal
            )
        }
    }

    private func publishWidgetState() {
        let defaults = UserDefaults(suiteName: "group.com.stillway.app")
        defaults?.set(localization.string(theme.displayedContext.localizationKey), forKey: "contextName")
        defaults?.set(localization.string(audio.primarySound.localizationKey), forKey: "soundName")
        defaults?.set(TimerRing.format(audio.remainingSeconds), forKey: "remaining")
        defaults?.set(audio.isPlaying, forKey: "isPlaying")
    }

    private func nearestPlace(places: [UserPlace]) -> UserPlace? {
        guard let current = location.currentLocation else { return nil }
        return places.min { $0.distance(to: current) < $1.distance(to: current) }.flatMap { place in
            place.distance(to: current) < 150 ? place : nil
        }
    }
}
