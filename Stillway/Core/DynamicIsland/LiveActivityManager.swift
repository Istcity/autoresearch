import Foundation
import ActivityKit

struct StillwayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contextName: String
        var soundName: String
        var remainingSeconds: Int
        var accentColorHex: String
        var isPlaying: Bool
    }

    var sessionName: String
}

@MainActor
final class LiveActivityManager {
    private var activity: Activity<StillwayActivityAttributes>?

    func start(contextName: String, soundName: String, remainingSeconds: Int, accentHex: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = StillwayActivityAttributes(sessionName: "Stillway")
        let state = StillwayActivityAttributes.ContentState(
            contextName: contextName,
            soundName: soundName,
            remainingSeconds: remainingSeconds,
            accentColorHex: accentHex,
            isPlaying: true
        )
        activity = try? Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
    }

    func update(contextName: String, soundName: String, remainingSeconds: Int, accentHex: String, isPlaying: Bool) {
        let state = StillwayActivityAttributes.ContentState(
            contextName: contextName,
            soundName: soundName,
            remainingSeconds: remainingSeconds,
            accentColorHex: accentHex,
            isPlaying: isPlaying
        )
        Task {
            await activity?.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }
    }
}
