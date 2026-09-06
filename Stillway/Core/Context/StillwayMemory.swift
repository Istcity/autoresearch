import Foundation

enum StillwayMemory {
    private static let onboardingKey = "stillway.onboardingCompleted.v1"
    private static let languageKey = "stillway.selectedLanguage"
    private static let lastSoundKey = "stillway.lastSoundID"
    private static let lastTimerKey = "stillway.lastTimerMinutes"

    static var onboardingCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }

    static var selectedLanguage: String? {
        get { UserDefaults.standard.string(forKey: languageKey) }
        set { UserDefaults.standard.set(newValue, forKey: languageKey) }
    }

    static var lastSoundID: String? {
        get { UserDefaults.standard.string(forKey: lastSoundKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastSoundKey) }
    }

    static var lastTimerMinutes: Int? {
        get {
            guard UserDefaults.standard.object(forKey: lastTimerKey) != nil else { return nil }
            return UserDefaults.standard.integer(forKey: lastTimerKey)
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: lastTimerKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastTimerKey)
            }
        }
    }

    static func markOnboardingCompleted() {
        onboardingCompleted = true
    }

    static func sync(from prefs: UserPreferences) {
        if prefs.onboardingCompleted { onboardingCompleted = true }
        selectedLanguage = prefs.selectedLanguage
        lastSoundID = prefs.lastSoundID
        lastTimerMinutes = prefs.lastTimerMinutes
    }

    static func apply(to prefs: UserPreferences) {
        if onboardingCompleted { prefs.onboardingCompleted = true }
        if let selectedLanguage { prefs.selectedLanguage = selectedLanguage }
        if let lastSoundID { prefs.lastSoundID = lastSoundID }
        if let lastTimerMinutes { prefs.lastTimerMinutes = lastTimerMinutes }
    }
}
