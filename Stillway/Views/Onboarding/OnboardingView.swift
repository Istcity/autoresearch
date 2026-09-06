import SwiftUI
import SwiftData
import UIKit

struct OnboardingView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(\.modelContext) private var modelContext
    @Query private var prefs: [UserPreferences]
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardPage1 { advanceFromFirst() }
                .tag(0)
            OnboardPage2(onContinue: { advanceFromSecond(openShortcuts: true) }, onSkip: { advanceFromSecond(openShortcuts: false) })
                .tag(1)
            OnboardPage3 { finish() }
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.95), value: currentPage)
        .onAppear { ensurePrefs() }
    }

    private func advanceFromFirst() {
        HapticEngine.tap()
        runtime.location.requestAlwaysAuthorization()
        currentPage = 1
    }

    private func advanceFromSecond(openShortcuts: Bool) {
        HapticEngine.tap()
        if openShortcuts, let url = URL(string: "shortcuts://") {
            UIApplication.shared.open(url)
            prefs.first?.shortcutOnboardingDone = true
        }
        currentPage = 2
    }

    private func finish() {
        HapticEngine.success()
        prefs.first?.onboardingCompleted = true
        runtime.completeOnboarding()
    }

    private func ensurePrefs() {
        if prefs.isEmpty { modelContext.insert(UserPreferences()) }
    }
}
