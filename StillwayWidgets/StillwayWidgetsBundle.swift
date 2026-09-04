import WidgetKit
import SwiftUI
import AppIntents

@main
struct StillwayWidgetBundle: WidgetBundle {
    var body: some Widget {
        HomeScreenWidget()
        LockScreenWidget()
        StillwayLiveActivity()
    }
}

typealias StillwayWidgetsBundle = StillwayWidgetBundle

struct ToggleStillwayIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Stillway"
    static var description = IntentDescription("Start or stop the current Stillway session.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.sinannergiz.stillway")
        defaults?.set(true, forKey: "pendingToggle")
        defaults?.set(Date().timeIntervalSince1970, forKey: "pendingToggleAt")
        return .result()
    }
}
