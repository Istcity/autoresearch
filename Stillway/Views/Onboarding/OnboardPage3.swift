import SwiftUI

struct OnboardPage3: View {
    var onBegin: () -> Void
    @Environment(LocalizationManager.self) private var lm
    @Environment(ThemeEngine.self) private var theme
    @State private var contexts: [AppContext] = [.commute, .focus, .sleep, .reset, .walking]
    @State private var index = 0

    var body: some View {
        ZStack {
            MeshBackgroundView().ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                WaveformView()
                    .frame(height: 180)
                    .scaleEffect(1.15)
                Text(lm.string("onboard_headline3"))
                    .font(.system(size: 34, weight: .light))
                    .multilineTextAlignment(.center)
                Text(lm.string("onboard_body3"))
                    .font(.system(size: 17))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Button(action: onBegin) {
                    PillButtonLabel(title: lm.string("btn_begin"))
                }
                .hapticButton()
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .task {
            theme.apply(.reset)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.4))
                index = (index + 1) % contexts.count
                theme.apply(contexts[index])
            }
        }
    }
}
