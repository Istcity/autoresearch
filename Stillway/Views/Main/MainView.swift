import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.lm) private var lm
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var store
    @Query private var preferences: [UserPreferences]
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            AtmosphereView()
                .ignoresSafeArea()

            RadialGradient(
                colors: [.clear, .black.opacity(0.42)],
                center: .center,
                startRadius: 60,
                endRadius: 480
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                ContextBadge(
                    context: theme.currentContext,
                    isAutomatic: runtime.triggerType == .automatic
                )

                if !runtime.audio.isUsingFileBed, runtime.audio.isPlaying {
                    Text(lm.string("toast_demo_noise"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.orange.opacity(0.9))
                        .padding(.top, 8)
                }

                Spacer(minLength: 8)

                WaveformView()
                    .frame(height: horizontalSizeClass == .compact ? 110 : 150)
                    .padding(.horizontal, 8)

                Spacer(minLength: 8)

                bottomControls
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.bottom, 8)

            if runtime.showAutoBanner {
                AutoStartBanner(text: lm.string("auto_banner"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .safeAreaPadding(.top, 8)
            }

            if let toast = runtime.toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                }
                .safeAreaPadding(.bottom, 8)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        runtime.toast = nil
                    }
                }
            }
        }
        .contextThemed()
        .onAppear { ensurePreferences() }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                HapticEngine.tap()
                runtime.showPlaces = true
            } label: {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial.opacity(0.35), in: Circle())
            }
            .accessibilityLabel(lm.string("places_title"))

            Spacer(minLength: 4)

            atmosphereChip
                .layoutPriority(1)

            Spacer(minLength: 4)

            Button {
                HapticEngine.tap()
                runtime.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial.opacity(0.35), in: Circle())
            }
            .accessibilityLabel(lm.string("settings_title"))
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            if runtime.audio.isPlaying {
                TimerRing(
                    progress: ringProgress,
                    seconds: runtime.audio.remainingSeconds
                )
            }

            StartStopButton(isPlaying: runtime.audio.isPlaying) {
                runtime.handleStartStop(preferences: preferences.first)
            }

            TimerSelector(
                selection: runtime.selectedTimerMinutes,
                remainingSeconds: nil
            ) { minutes in
                runtime.selectTimer(minutes)
            }

            SoundMixerRow(
                sound: runtime.audio.primarySound ?? Sound.find("tokyo_rain")!,
                volume: Bindable(runtime.audio).primaryVolume,
                secondaryVolume: Bindable(runtime.audio).secondaryVolume,
                isPro: store.isPro || preferences.first?.isPro == true
            ) {
                runtime.showSounds = true
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
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
                .tracking(1.2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(theme.gradient.accentColor.opacity(0.95))
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(theme.gradient.accentColor.opacity(0.14), in: Capsule())
        .overlay(Capsule().stroke(theme.gradient.accentColor.opacity(0.25), lineWidth: 0.8))
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
        runtime.prepareDefaultAtmosphereIfNeeded()
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
