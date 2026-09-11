import SwiftUI

/// Facade — picks the living face for the active context.
struct TimerRing: View {
    var progress: Double
    var seconds: Int
    var face: TimerFaceKind? = nil
    @Environment(ThemeEngine.self) private var theme

    private var resolved: TimerFaceKind {
        face ?? .resolve(context: theme.currentContext)
    }

    var body: some View {
        TimerFaceView(kind: resolved, progress: progress, seconds: seconds)
            .id(resolved) // soft rebuild on context/face change
    }

    static func format(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
