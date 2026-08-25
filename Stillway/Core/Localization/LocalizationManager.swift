import Foundation
import Observation
import SwiftUI

@Observable
final class LocalizationManager {
    var currentLanguage: LanguageCode {
        didSet {
            loadBundle()
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
        }
    }

    var selectedLanguage: String {
        get { currentLanguage.rawValue }
        set { currentLanguage = LanguageCode(rawValue: newValue) ?? .en }
    }

    var current: LanguageCode { currentLanguage }
    var locale: Locale { currentLanguage.locale }

    private var bundle: Bundle = .main

    init() {
        if let stored = UserDefaults.standard.string(forKey: Self.storageKey),
           let code = LanguageCode(rawValue: stored) {
            currentLanguage = code
        } else {
            currentLanguage = LanguageCode.detect()
        }
        loadBundle()
    }

    func string(_ key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        if value != key { return value }
        if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let english = Bundle(path: path) {
            return english.localizedString(forKey: key, value: key, table: "Localizable")
        }
        return key
    }

    private func loadBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let loaded = Bundle(path: path) {
            bundle = loaded
        } else {
            bundle = .main
        }
    }

    static func autoDetect() -> String {
        LanguageCode.detect().rawValue
    }

    private static let storageKey = "selectedLanguage"
}

private struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager()
}

extension EnvironmentValues {
    var lm: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}
