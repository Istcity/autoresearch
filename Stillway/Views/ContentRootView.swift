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
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.6), value: prefs.first?.onboardingCompleted)
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
            guard url.host == "toggle" else { return }
            runtime.handleStartStop(preferences: prefs.first)
        }
    }
}
