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
            AtmosphereView()
                .ignoresSafeArea()

            // Soft vignette for premium depth
            RadialGradient(
                colors: [.clear, .black.opacity(0.45)],
                center: .center,
                startRadius: 80,
                endRadius: 520
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack {
                    Button {
                        HapticEngine.tap()
                        runtime.showPlaces = true
                    } label: {
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial.opacity(0.35), in: Circle())
                    }
                    .accessibilityLabel(lm.string("places_title"))
                    Spacer()
                    atmosphereChip
                    Spacer()
                    Button {
                        HapticEngine.tap()
                        runtime.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial.opacity(0.35), in: Circle())
                    }
                    .accessibilityLabel(lm.string("settings_title"))
                }
                .padding(.top, 56)
                .padding(.horizontal, 22)

                Spacer(minLength: 24)

                ContextBadge(
                    context: theme.currentContext,
                    isAutomatic: runtime.triggerType == .automatic
                )

                Spacer(minLength: 16)

                WaveformView()
                    .frame(height: 150)
                    .padding(.horizontal, 8)

                Spacer(minLength: 16)

                if runtime.audio.isPlaying {
                    TimerRing(
                        progress: ringProgress,
                        seconds: runtime.audio.remainingSeconds
                    )
                    .padding(.bottom, 12)
                }

                StartStopButton(isPlaying: runtime.audio.isPlaying) {
                    runtime.handleStartStop(preferences: preferences.first)
                }
                .padding(.bottom, 20)

                TimerSelector(
                    selection: runtime.selectedTimerMinutes,
                    remainingSeconds: nil
                ) { minutes in
                    runtime.selectTimer(minutes)
                }
                .padding(.bottom, 16)

                SoundMixerRow(
                    sound: runtime.audio.primarySound ?? Sound.find("tokyo_rain")!,
                    volume: Bindable(runtime.audio).primaryVolume,
                    secondaryVolume: Bindable(runtime.audio).secondaryVolume,
                    isPro: store.isPro || preferences.first?.isPro == true
                ) {
                    runtime.showSounds = true
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
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

    private var atmosphereChip: some View {
        let kind = AtmosphereKind.resolve(
            soundID: runtime.audio.primarySound?.id,
            context: theme.currentContext
        )
        return HStack(spacing: 6) {
            Image(systemName: kind.symbol)
                .font(.system(size: 11, weight: .semibold))
            Text("STILLWAY")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.4)
        }
        .foregroundStyle(theme.gradient.accentColor.opacity(0.9))
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(theme.gradient.accentColor.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(theme.gradient.accentColor.opacity(0.2), lineWidth: 0.8))
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
