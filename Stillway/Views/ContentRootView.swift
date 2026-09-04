import SwiftUI
import SwiftData

struct ContentRootView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var prefs: [UserPreferences]

    var body: some View {
        ZStack {
            if prefs.first?.onboardingCompleted == true {
                MainView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 1.0), value: prefs.first?.onboardingCompleted)
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
            consumePendingToggle()
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
