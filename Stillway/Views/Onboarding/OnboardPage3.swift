import SwiftUI

struct OnboardPage3: View {
    var onBegin: () -> Void
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme
    @State private var contexts: [AppContext] = [.commute, .focus, .sleep, .reset, .walking]
    @State private var index = 0

    var body: some View {
        ZStack {
            MeshBackgroundView().ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                WaveformView()
                    .frame(maxHeight: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                GradientText(
                    text: lm.string("onboard_3_title"),
                    colors: theme.gradient.waveColors
                )
                .font(.system(size: 34, weight: .light))
                .multilineTextAlignment(.center)
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
        .task {
            theme.apply(context: .reset)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.4))
                index = (index + 1) % contexts.count
                theme.apply(context: contexts[index])
            }
        }
    }
}
