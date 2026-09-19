import SwiftUI

struct OnboardPage3: View {
    var onBegin: () -> Void
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme

    var body: some View {
        ZStack {
            // Fixed, strong reset/forest aura — no context carousel (not a journey app).
            AtmosphereView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            RadialGradient(
                colors: [
                    theme.gradient.glowColor.opacity(0.55),
                    .clear,
                    .black.opacity(0.55)
                ],
                center: .center,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 28) {
                Spacer()
                WaveformView()
                    .frame(height: UIScreen.main.bounds.height * 0.28)
                    .padding(.horizontal, 12)
                GradientText(
                    text: lm.string("onboard_3_title"),
                    colors: theme.gradient.waveColors
                )
                .font(.system(size: 34, weight: .light))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                Text(lm.string("onboard_3_body"))
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                PillButton(label: lm.string("onboard_3_btn"), action: onBegin)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            theme.setImmediate(.reset)
        }
    }
}
