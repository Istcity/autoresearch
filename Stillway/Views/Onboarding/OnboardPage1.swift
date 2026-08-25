import SwiftUI

struct OnboardPage1: View {
    var onContinue: () -> Void
    @Environment(LocalizationManager.self) private var lm
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        ZStack {
            MeshBackgroundView().ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Image(systemName: "tram.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(theme.gradient.accentColor)
                    .symbolEffect(.pulse, options: .repeating)
                WaveformView().frame(height: 120)
                Text(lm.string("onboard_headline1"))
                    .font(.system(size: 34, weight: .light))
                    .multilineTextAlignment(.center)
                Text(lm.string("onboard_body1"))
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Button {
                    runtime.location.requestAlways()
                    onContinue()
                } label: {
                    PillButtonLabel(title: lm.string("btn_allow_location"))
                }
                .hapticButton()
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .padding(.top, 80)
        }
        .onAppear { theme.apply(.commute) }
    }
}
