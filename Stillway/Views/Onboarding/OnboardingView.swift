import SwiftUI

struct OnboardingView: View {
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(LocalizationManager.self) private var lm
    @State private var page = 0

    var body: some View {
        ZStack {
            switch page {
            case 0: OnboardPage1 { advance() }
            case 1: OnboardPage2(onContinue: { advance() }, onSkip: { advance() })
            default: OnboardPage3 { runtime.completeOnboarding() }
            }
        }
        .animation(.easeInOut(duration: 0.55), value: page)
    }

    private func advance() {
        HapticEngine.tap()
        page = min(2, page + 1)
    }
}
