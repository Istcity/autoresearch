import SwiftUI

struct ContentRootView: View {
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if runtime.hasCompletedOnboarding {
                MainView()
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.6), value: runtime.hasCompletedOnboarding)
        .onOpenURL { url in
            guard url.host == "toggle" else { return }
            runtime.handleStartStop(preferences: nil)
        }
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
    }
}
