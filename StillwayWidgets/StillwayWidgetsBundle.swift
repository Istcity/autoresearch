import WidgetKit
import SwiftUI
import AppIntents

@main
struct StillwayWidgetsBundle: WidgetBundle {
    var body: some Widget {
        LockScreenWidget()
        HomeScreenWidget()
        StillwayLiveActivity()
    }
}

struct ToggleStillwayIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Stillway"
    static var description = IntentDescription("Start or stop the current Stillway session.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
