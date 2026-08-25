import Foundation
import Observation
import SwiftData
import CoreLocation

@Observable
@MainActor
final class ContextEngine {
    let audioEngine = AudioEngine()
    let themeEngine = ThemeEngine()
    let locationManager = LocationManager.shared
    let geofenceManager = GeofenceManager()
    let motionClassifier = MotionClassifier()
    let sleepDetector = SleepDetector()
    let stations = StationDatabase.shared
    let breathing = HapticBreathingEngine()
    let liveActivity = LiveActivityManager()

    var visitTracker: VisitTracker?

    var currentContext: AppContext = .unknown
    var triggerType: TriggerType = .manual
    var activeStationID: String?
    var latestDecision = ContextDecision(
        context: .unknown,
        shouldAutoStart: false,
        triggerType: .manual,
        suggestedSoundID: "tokyo_rain",
        confidence: 0
    )

    var selectedTimerMinutes: Int? = 30
    var showSettings = false
    var showPlaces = false
    var showSounds = false
    var showPlaceLabel = false
    var showAutoBanner = false
    var toast: String?
    var pendingLabelPlace: UserPlace? { visitTracker?.pendingLabelPlace }

    var audio: AudioEngine { audioEngine }
    var theme: ThemeEngine { themeEngine }
    var location: LocationManager { locationManager }
    var geofence: GeofenceManager { geofenceManager }
    var motion: MotionClassifier { motionClassifier }
    var localization = LocalizationManager()

    private var modelContext: ModelContext?
    private var isConfigured = false
    private var tickTask: Task<Void, Never>?
    private var placeObserver: NSObjectProtocol?
    private var sleepObserver: NSObjectProtocol?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        visitTracker = VisitTracker(modelContext: modelContext)
        guard !isConfigured else { return }
        isConfigured = true
        geofenceManager.setup()
        locationManager.onVisit = { [weak self] visit in
            self?.handleVisit(visit)
        }
        locationManager.onSignificantChange = { [weak self] location in
            self?.handleLocation(location)
        }
        geofenceManager.onTransitEntry = { [weak self] station in
            self?.handleStationEnter(station)
        }
        sleepDetector.onSleepPrompt = { [weak self] in
            self?.toast = self?.localization.string("notif_sleep")
        }
        placeObserver = NotificationCenter.default.addObserver(forName: .placeNeedsLabel, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.showPlaceLabel = true
            }
        }
        sleepObserver = NotificationCenter.default.addObserver(forName: .sleepPromptNeeded, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.toast = self?.localization.string("notif_sleep")
            }
        }
        motionClassifier.start()
        locationManager.startAllServices()
        sleepDetector.startMonitoring(motion: motionClassifier, location: locationManager)
        startTicker()
    }

    func startServices(modelContext: ModelContext) {
        configure(modelContext: modelContext)
    }

    func startManually(context: AppContext, sound: Sound) {
        currentContext = context
        triggerType = .manual
        themeEngine.apply(context: context)
        audioEngine.primarySound = sound
        audioEngine.setTimer(minutes: selectedTimerMinutes)
        audioEngine.play(sound: sound)
        if let minutes = selectedTimerMinutes {
            audioEngine.startJourneyArc(minutes: Double(minutes))
        }
        liveActivity.start(
            contextName: localization.string(context.localizationKey),
            soundName: localization.string(sound.localizationKey),
            totalMinutes: selectedTimerMinutes ?? 30,
            accentHex: "4169E1"
        )
        if let modelContext {
            modelContext.insert(CommutSession(context: context, soundID: sound.id, triggeredAutomatically: false))
        }
        NotificationCenter.default.post(name: .contextDidChange, object: context.rawValue)
    }

    func stop() {
        audioEngine.stop()
        liveActivity.end()
        breathing.stop()
        triggerType = .manual
        toast = localization.string("toast_stopped")
    }

    func handleStartStop(preferences: UserPreferences?) {
        if audioEngine.isPlaying {
            stop()
        } else {
            let sound = Sound.find(preferences?.lastSoundID ?? audioEngine.primarySound?.id ?? "tokyo_rain") ?? Sound.library[4]
            startManually(context: sound.context, sound: sound)
            toast = localization.string("toast_started")
            HapticEngine.tap()
        }
    }

    func selectSound(_ sound: Sound, isPro: Bool, preferences: UserPreferences?) {
        if !sound.isFree && !isPro {
            showSettings = true
            return
        }
        audioEngine.primarySound = sound
        preferences?.lastSoundID = sound.id
        themeEngine.apply(context: sound.context)
        if audioEngine.isPlaying {
            audioEngine.play(sound: sound)
        }
        HapticEngine.select()
    }

    func selectTimer(_ minutes: Int?) {
        selectedTimerMinutes = minutes
        audioEngine.setTimer(minutes: minutes)
        HapticEngine.select()
    }

    func completeOnboarding() {
        locationManager.requestAlwaysAuthorization()
    }

    private func startTicker() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.audioEngine.updateJourneyArc()
                self?.publishWidgetState()
                if let self, self.audioEngine.isPlaying {
                    self.liveActivity.update(remainingSeconds: self.audioEngine.remainingSeconds)
                }
            }
        }
    }

    private func handleVisit(_ visit: CLVisit) {
        visitTracker?.process(visit: visit)
        if visitTracker?.pendingLabelPlace != nil {
            showPlaceLabel = true
        }
        reevaluate()
    }

    private func handleLocation(_ location: CLLocation) {
        geofenceManager.refresh(near: location.coordinate)
        if let prefs = fetchPreferences() {
            prefs.lastKnownLatitude = location.coordinate.latitude
            prefs.lastKnownLongitude = location.coordinate.longitude
        }
        reevaluate()
    }

    private func handleStationEnter(_ station: Station) {
        activeStationID = station.id
        reevaluate()
    }

    private func reevaluate() {
        guard let modelContext else { return }
        let places = (try? modelContext.fetch(FetchDescriptor<UserPlace>())) ?? []
        let preferences = fetchPreferences() ?? {
            let created = UserPreferences()
            modelContext.insert(created)
            return created
        }()
        guard preferences.contextDetectionEnabled else { return }

        let nearest = nearestPlace(places: places)
        sleepDetector.configure(preferences: preferences, homePlace: places.first(where: { $0.label == .home }))

        let decision = evaluate(
            headphones: audioEngine.isHeadphonesConnected,
            stationID: activeStationID,
            activity: motionClassifier.currentActivity,
            nearest: nearest,
            preferences: preferences,
            isPro: preferences.isPro,
            isHorizontal: motionClassifier.isPhoneHorizontal
        )
        latestDecision = decision
        currentContext = decision.context
        triggerType = decision.triggerType
        themeEngine.apply(context: decision.context)

        if decision.shouldAutoStart, !audioEngine.isPlaying, let sound = Sound.find(decision.suggestedSoundID) {
            startManually(context: decision.context, sound: sound)
            showAutoBanner = true
            NotificationCenter.default.post(name: .autoSessionTriggered, object: decision.context.rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                self?.showAutoBanner = false
            }
        }

        if let currentLocation = locationManager.currentLocation {
            sleepDetector.checkSleepConditions(
                preferences: preferences,
                places: places,
                currentLocation: currentLocation,
                motionActivity: motionClassifier.latestActivity,
                isPhoneHorizontal: motionClassifier.isPhoneHorizontal
            )
        }
    }

    private func evaluate(
        headphones: Bool,
        stationID: String?,
        activity: ActivityState,
        nearest: UserPlace?,
        preferences: UserPreferences,
        isPro: Bool,
        isHorizontal: Bool
    ) -> ContextDecision {
        let hour = Calendar.current.component(.hour, from: Date())
        if stationID != nil, headphones {
            return ContextDecision(context: .commute, shouldAutoStart: isPro, triggerType: headphones ? .automatic : .suggested, suggestedSoundID: "tokyo_metro", confidence: 0.92)
        }
        if activity == .automotive {
            return ContextDecision(context: .commute, shouldAutoStart: isPro && headphones, triggerType: headphones ? .automatic : .suggested, suggestedSoundID: "shinkansen", confidence: 0.8)
        }
        if preferences.sleepModeEnabled,
           nearest?.label == .home,
           hour >= preferences.sleepStartHour || hour < preferences.sleepEndHour,
           activity.isStationary,
           isHorizontal {
            return ContextDecision(context: .sleep, shouldAutoStart: isPro, triggerType: .suggested, suggestedSoundID: "night_forest", confidence: 0.78)
        }
        if let nearest, nearest.label == .work || nearest.label == .library, (9...18).contains(hour) {
            return ContextDecision(context: .focus, shouldAutoStart: isPro && nearest.autoStartEnabled && headphones, triggerType: nearest.autoStartEnabled ? .automatic : .suggested, suggestedSoundID: nearest.defaultSoundID ?? "tokyo_rain", confidence: 0.74)
        }
        if activity == .walking, headphones {
            return ContextDecision(context: .reset, shouldAutoStart: false, triggerType: .suggested, suggestedSoundID: "kyoto_bamboo", confidence: 0.6)
        }
        return ContextDecision(context: .unknown, shouldAutoStart: false, triggerType: .manual, suggestedSoundID: preferences.lastSoundID, confidence: 0.2)
    }

    private func fetchPreferences() -> UserPreferences? {
        guard let modelContext else { return nil }
        return try? modelContext.fetch(FetchDescriptor<UserPreferences>()).first
    }

    private func publishWidgetState() {
        let defaults = UserDefaults(suiteName: "group.com.stillway.app")
        defaults?.set(localization.string(themeEngine.currentContext.localizationKey), forKey: "contextName")
        defaults?.set(localization.string((audioEngine.primarySound ?? Sound.find("tokyo_rain")!).localizationKey), forKey: "soundName")
        defaults?.set(TimerRing.format(audioEngine.remainingSeconds), forKey: "remaining")
        defaults?.set(audioEngine.isPlaying, forKey: "isPlaying")
    }

    private func nearestPlace(places: [UserPlace]) -> UserPlace? {
        guard let current = locationManager.currentLocation else { return nil }
        return places.min { $0.distance(to: current) < $1.distance(to: current) }.flatMap { place in
            place.distance(to: current) < 150 ? place : nil
        }
    }
}

struct ContextDecision: Equatable {
    var context: AppContext
    var shouldAutoStart: Bool
    var triggerType: TriggerType
    var suggestedSoundID: String
    var confidence: Double
}

typealias StillwayRuntime = ContextEngine
