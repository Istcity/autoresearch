import Foundation

enum LanguageCode: String, CaseIterable, Identifiable, Codable, Sendable {
    case tr
    case ja
    case en
    case fr

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tr: return "Türkçe"
        case .ja: return "日本語"
        case .en: return "English"
        case .fr: return "Français"
        }
    }

    var flag: String {
        switch self {
        case .tr: return "🇹🇷"
        case .ja: return "🇯🇵"
        case .en: return "🇺🇸"
        case .fr: return "🇫🇷"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    static func detect() -> LanguageCode {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return LanguageCode(rawValue: code) ?? .en
    }

    static func autoDetect() -> LanguageCode { detect() }
}
