import SwiftUI
import SwiftData

struct ContentRootView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext
    @Query private var prefs: [UserPreferences]

    private var hasCompletedOnboarding: Bool {
        StillwayMemory.onboardingCompleted || prefs.first?.onboardingCompleted == true
    }

    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 1.0), value: hasCompletedOnboarding)
        .sheet(isPresented: Bindable(runtime).showSettings) {
            SettingsSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: Bindable(runtime).showPlaces) {
            PlacesSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: Bindable(runtime).showSounds) {
            SoundPickerSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: Bindable(runtime).showPlaceLabel) {
            PlaceLabelSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .onAppear {
            reconcileOnboardingFlag()
            consumePendingToggle()
        }
    }

    private func reconcileOnboardingFlag() {
        if StillwayMemory.onboardingCompleted, let prefs = prefs.first, !prefs.onboardingCompleted {
            prefs.onboardingCompleted = true
            try? modelContext.save()
        }
        if let prefs = prefs.first, prefs.onboardingCompleted {
            StillwayMemory.markOnboardingCompleted()
            StillwayMemory.sync(from: prefs)
        }
    }

    private func handleDeepLink(_ url: URL) {
        switch url.host {
        case "toggle":
            runtime.handleStartStop(preferences: prefs.first)
        case "sounds":
            runtime.showSounds = true
        case "places":
            runtime.showPlaces = true
        case "settings":
            runtime.showSettings = true
        default:
            break
        }
    }

    private func consumePendingToggle() {
        let defaults = UserDefaults(suiteName: "group.com.sinannergiz.stillway")
        guard defaults?.bool(forKey: "pendingToggle") == true else { return }
        defaults?.set(false, forKey: "pendingToggle")
        runtime.handleStartStop(preferences: prefs.first)
    }
}
