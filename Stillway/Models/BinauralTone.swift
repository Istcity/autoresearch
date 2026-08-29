import Foundation

/// Selectable binaural / carrier tone layer for focus and sleep mixes.
enum BinauralTone: String, CaseIterable, Codable, Sendable, Identifiable, Hashable {
    case off
    case delta
    case theta
    case alpha
    case beta

    var id: String { rawValue }

    /// Beat frequency in Hz (carrier offset). `off` is silent.
    var beatHz: Double {
        switch self {
        case .off: return 0
        case .delta: return 2.5
        case .theta: return 6
        case .alpha: return 10
        case .beta: return 16
        }
    }

    var localizationKey: String {
        switch self {
        case .off: return "binaural_off"
        case .delta: return "binaural_delta"
        case .theta: return "binaural_theta"
        case .alpha: return "binaural_alpha"
        case .beta: return "binaural_beta"
        }
    }
}
