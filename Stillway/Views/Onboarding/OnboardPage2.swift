import SwiftUI

struct OnboardPage2: View {
    var onContinue: () -> Void
    var onSkip: () -> Void
    @Environment(LocalizationManager.self) private var lm
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        ZStack {
            MeshBackgroundView().ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Image(systemName: "airpodspro")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(theme.gradient.accentColor)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                WaveformView().frame(height: 120)
                Text(lm.string("onboard_headline2"))
                    .font(.system(size: 34, weight: .light))
                    .multilineTextAlignment(.center)
                Text(lm.string("onboard_body2"))
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Button(action: onContinue) {
                    PillButtonLabel(title: lm.string("btn_setup_shortcut"))
                }
                .hapticButton()
                .padding(.horizontal, 24)
                Button(lm.string("btn_not_now") + " →", action: onSkip)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.bottom, 48)
            }
            .padding(.top, 80)
        }
        .onAppear { theme.apply(.focus) }
    }
}
