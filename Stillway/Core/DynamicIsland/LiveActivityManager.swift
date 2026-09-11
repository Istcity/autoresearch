import Foundation
import ActivityKit
import Observation

struct StillwayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contextName: String
        var soundName: String
        var remainingSeconds: Int
        var accentColorHex: String
        var isPlaying: Bool
        var atmosphereKind: String
    }

    var sessionName: String
}

@Observable
@MainActor
final class LiveActivityManager {
    private var activity: Activity<StillwayActivityAttributes>?

    func start(contextName: String, soundName: String, totalMinutes: Int, accentHex: String, atmosphereKind: String = "mist") {
        start(
            contextName: contextName,
            soundName: soundName,
            remainingSeconds: totalMinutes * 60,
            accentHex: accentHex,
            atmosphereKind: atmosphereKind
        )
    }

    func start(
        contextName: String,
        soundName: String,
        remainingSeconds: Int,
        accentHex: String,
        atmosphereKind: String = "mist"
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = StillwayActivityAttributes(sessionName: "Stillway")
        let state = StillwayActivityAttributes.ContentState(
            contextName: contextName,
            soundName: soundName,
            remainingSeconds: max(0, remainingSeconds),
            accentColorHex: accentHex,
            isPlaying: true,
            atmosphereKind: atmosphereKind
        )
        let stale = Date().addingTimeInterval(TimeInterval(max(60, remainingSeconds + 120)))
        Task {
            for existing in Activity<StillwayActivityAttributes>.activities {
                await existing.end(nil, dismissalPolicy: .immediate)
            }
            self.activity = try? Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: stale)
            )
        }
    }

    func update(remainingSeconds: Int) {
        guard var state = activity?.content.state else { return }
        state.remainingSeconds = max(0, remainingSeconds)
        let stale = Date().addingTimeInterval(TimeInterval(max(60, remainingSeconds + 120)))
        Task { await activity?.update(.init(state: state, staleDate: stale)) }
        if remainingSeconds <= 0 {
            end()
        }
    }

    func update(
        contextName: String,
        soundName: String,
        remainingSeconds: Int,
        accentHex: String,
        isPlaying: Bool,
        atmosphereKind: String
    ) {
        let state = StillwayActivityAttributes.ContentState(
            contextName: contextName,
            soundName: soundName,
            remainingSeconds: max(0, remainingSeconds),
            accentColorHex: accentHex,
            isPlaying: isPlaying,
            atmosphereKind: atmosphereKind
        )
        let stale = Date().addingTimeInterval(TimeInterval(max(60, remainingSeconds + 120)))
        Task { await activity?.update(.init(state: state, staleDate: stale)) }
    }

    func end() {
        Task {
            await endAllStale()
            activity = nil
        }
    }

    /// Dismiss orphaned Live Activities left over after force-quit or crash.
    func endAllStale() async {
        for existing in Activity<StillwayActivityAttributes>.activities {
            await existing.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}
