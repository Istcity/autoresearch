import SwiftUI
import SwiftData

@main
struct StillwayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var contextEngine = ContextEngine()
    @State private var purchaseManager = PurchaseManager()
    @State private var lm = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            ContentRootView()
                .environment(contextEngine)
                .environment(contextEngine.themeEngine)
                .environment(contextEngine.audioEngine)
                .environment(purchaseManager)
                .environment(\.lm, lm)
                .preferredColorScheme(.dark)
                .supportedInterfaceOrientations(.portrait)
                .onAppear {
                    contextEngine.localization = lm
                    contextEngine.configure(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

private let sharedModelContainer: ModelContainer = {
    let schema = Schema([UserPlace.self, CommutSession.self, UserPreferences.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
    do {
        return try ModelContainer(for: schema, configurations: configuration)
    } catch {
        return try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
}()
