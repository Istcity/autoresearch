import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(ThemeEngine.self) private var theme
    @Environment(LocalizationManager.self) private var lm
    @Query private var preferences: [UserPreferences]

    var body: some View {
        ZStack {
            MeshBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                ContextBadge(
                    context: theme.displayedContext,
                    isAutomatic: runtime.contextEngine.latestDecision.triggerType == .automatic
                )
                .padding(.top, 60)
                Spacer()
                WaveformView()
                    .frame(height: UIScreen.main.bounds.height * 0.35)
                Spacer()
                StartStopButton(isPlaying: runtime.audio.isPlaying) {
                    runtime.handleStartStop(preferences: preferences.first)
                }
                .padding(.bottom, 32)
                TimerSelector(
                    selection: runtime.selectedTimerMinutes,
                    remainingSeconds: runtime.audio.isPlaying ? runtime.audio.remainingSeconds : nil
                ) { minutes in
                    runtime.selectTimer(minutes)
                }
                .padding(.bottom, 20)
                SoundMixerRow(
                    sound: runtime.audio.primarySound,
                    volume: Bindable(runtime.audio).primaryVolume
                ) {
                    runtime.showSounds = true
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            VStack {
                HStack {
                    Button {
                        HapticEngine.tap()
                        runtime.showPlaces = true
                    } label: {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .accessibilityLabel(lm.string("places_title"))
                    Spacer()
                    Button {
                        HapticEngine.tap()
                        runtime.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .accessibilityLabel(lm.string("settings_title"))
                }
                .padding(.top, 56)
                .padding(.horizontal, 24)
                Spacer()
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
        .onAppear {
            ensurePreferences()
        }
    }

    @Environment(\.modelContext) private var modelContext

    private func ensurePreferences() {
        if preferences.isEmpty {
            modelContext.insert(UserPreferences())
        }
    }
}
