import SwiftUI
import SwiftData

@main
struct StillwayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var runtime = StillwayRuntime()

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environment(runtime)
                .environment(runtime.theme)
                .environment(runtime.localization)
                .preferredColorScheme(.dark)
                .statusBarHidden(false)
                .onAppear {
                    runtime.startServices(modelContext: runtimeModelContainer.mainContext)
                }
        }
        .modelContainer(runtimeModelContainer)
    }
}

private let runtimeModelContainer: ModelContainer = {
    let schema = Schema([UserPlace.self, CommuteSession.self, UserPreferences.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
    do {
        return try ModelContainer(for: schema, configurations: configuration)
    } catch {
        return try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}()
