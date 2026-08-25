import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.lm) private var lm
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var store
    @Query private var preferences: [UserPreferences]

    var body: some View {
        ZStack {
            MeshBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        HapticEngine.tap()
                        runtime.showPlaces = true
                    } label: {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .accessibilityLabel(lm.string("places_title"))
                    Spacer()
                    Button {
                        HapticEngine.tap()
                        runtime.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .accessibilityLabel(lm.string("settings_title"))
                }
                .padding(.top, 56)
                .padding(.horizontal, 24)

                Spacer()
                ContextBadge(
                    context: theme.currentContext,
                    isAutomatic: runtime.triggerType == .automatic
                )
                Spacer()
                WaveformView()
                    .frame(height: 160)
                Spacer()
                if runtime.audio.isPlaying {
                    TimerRing(
                        progress: ringProgress,
                        seconds: runtime.audio.remainingSeconds
                    )
                    .padding(.bottom, 16)
                }
                StartStopButton(isPlaying: runtime.audio.isPlaying) {
                    runtime.handleStartStop(preferences: preferences.first)
                }
                .padding(.bottom, 24)
                TimerSelector(
                    selection: runtime.selectedTimerMinutes,
                    remainingSeconds: nil
                ) { minutes in
                    runtime.selectTimer(minutes)
                }
                .padding(.bottom, 20)
                SoundMixerRow(
                    sound: runtime.audio.primarySound ?? Sound.find("tokyo_rain")!,
                    volume: Bindable(runtime.audio).primaryVolume,
                    secondaryVolume: Bindable(runtime.audio).secondaryVolume,
                    isPro: store.isPro || preferences.first?.isPro == true
                ) {
                    runtime.showSounds = true
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            if runtime.showAutoBanner {
                AutoStartBanner(text: lm.string("auto_banner"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 96)
                    .frame(maxHeight: .infinity, alignment: .top)
            }

            if let toast = runtime.toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        runtime.toast = nil
                    }
                }
            }
        }
        .contextThemed()
        .onAppear { ensurePreferences() }
    }

    private var ringProgress: Double {
        let total = Double((runtime.selectedTimerMinutes ?? 45) * 60)
        guard total > 0 else { return 0 }
        return 1 - Double(runtime.audio.remainingSeconds) / total
    }

    private func ensurePreferences() {
        if preferences.isEmpty {
            modelContext.insert(UserPreferences())
        }
    }
}

private struct AutoStartBanner: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            PulsingDot()
            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
