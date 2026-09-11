import SwiftUI

/// Metaphorical remaining-time faces — Stillway’s signature timer language.
enum TimerFaceKind: String, CaseIterable, Identifiable, Sendable {
    case ring
    case hourglass
    case waterDrop
    case classic
    case sundial
    case moon
    case tide
    case ember
    case mist
    case breath

    var id: String { rawValue }

    /// Context + time-of-day — all ten faces appear in real use.
    static func resolve(context: AppContext, date: Date = .now) -> TimerFaceKind {
        let hour = Calendar.current.component(.hour, from: date)
        switch context {
        case .focus:
            return hour < 14 ? .hourglass : .breath
        case .reset:
            return .waterDrop
        case .unknown:
            return hour % 2 == 0 ? .classic : .ring
        case .walking:
            return (6..<18).contains(hour) ? .sundial : .mist
        case .sleep:
            return .moon
        case .commute:
            return .tide
        case .deepWork:
            return .ember
        }
    }

    var symbol: String {
        switch self {
        case .ring: return "circle.dashed"
        case .hourglass: return "hourglass"
        case .waterDrop: return "drop.fill"
        case .classic: return "clock"
        case .sundial: return "sun.max.fill"
        case .moon: return "moon.fill"
        case .tide: return "water.waves"
        case .ember: return "flame.fill"
        case .mist: return "cloud.fog.fill"
        case .breath: return "circle.circle"
        }
    }
}
