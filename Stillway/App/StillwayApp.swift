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
                .onAppear {
                    contextEngine.localization = lm
                    contextEngine.configure(modelContext: sharedModelContainer.mainContext)
                    restorePreferences(into: sharedModelContainer.mainContext)
                    if StillwayTesting.unlockAllFeatures {
                        purchaseManager.unlockForPreview()
                        contextEngine.unlockAllFeaturesForTesting()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func restorePreferences(into context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<UserPreferences>())) ?? []
        let prefs: UserPreferences
        if let first = existing.first {
            prefs = first
        } else {
            prefs = UserPreferences()
            context.insert(prefs)
        }
        StillwayMemory.apply(to: prefs)
        if let language = StillwayMemory.selectedLanguage {
            lm.currentLanguage = LanguageCode(rawValue: language) ?? .en
        }
        try? context.save()
    }
}

private let sharedModelContainer: ModelContainer = {
    let schema = Schema([UserPlace.self, CommuteSession.self, UserPreferences.self])
    let url = URL.applicationSupportDirectory.appending(path: "Stillway.store")

    do {
        return try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(url: url)
        )
    } catch {
        // Schema changed — wipe incompatible store and recreate on disk (never prefer memory-only).
        try? FileManager.default.removeItem(at: url)
        for ext in ["store-shm", "store-wal"] {
            let side = url.deletingPathExtension().appendingPathExtension(ext)
            try? FileManager.default.removeItem(at: side)
        }
        do {
            return try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(url: url)
            )
        } catch {
            assertionFailure("Stillway SwiftData failed twice: \(error)")
            return try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }
}()
