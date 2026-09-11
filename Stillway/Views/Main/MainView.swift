import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.lm) private var lm
    @Environment(\.modelContext) private var modelContext
    @Environment(PurchaseManager.self) private var store
    @Query private var preferences: [UserPreferences]
    /// Tap the timer to preview all faces; nil = context-auto.
    @State private var faceOverride: TimerFaceKind?

    var body: some View {
        ZStack {
            AtmosphereView()
                .ignoresSafeArea()

            // Soft vignette — depth without hard edges
            RadialGradient(
                colors: [.clear, .black.opacity(0.48)],
                center: .center,
                startRadius: 90,
                endRadius: 540
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                Spacer(minLength: 28)

                contextHero

                Spacer(minLength: 20)

                WaveformView()
                    .frame(height: 168)
                    .padding(.horizontal, 4)

                Spacer(minLength: 20)

                bottomControls
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.bottom, 10)

            if runtime.showAutoBanner {
                AutoStartBanner(text: lm.string("auto_banner"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 72)
                    .frame(maxHeight: .infinity, alignment: .top)
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
                        .padding(.bottom, 16)
                }
                .safeAreaPadding(.bottom, 8)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        runtime.toast = nil
                    }
                }
            }
        }
        .contextThemed()
        .onAppear {
            ensurePreferences()
            if preferences.first?.didRequestLocationPermission != true {
                Task { await runtime.requestStartupPermissions() }
            }
        }
        .onChange(of: theme.currentContext) { _, _ in
            faceOverride = nil
        }
    }

    // MARK: - Top

    private var topBar: some View {
        HStack {
            iconButton(systemName: "location.north.fill", label: lm.string("places_title")) {
                runtime.showPlaces = true
            }
            Spacer()
            brandMark
            Spacer()
            iconButton(systemName: "gearshape.fill", label: lm.string("settings_title")) {
                runtime.showSettings = true
            }
        }
    }

    private var brandMark: some View {
        Text("STILLWAY")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .tracking(3.2)
            .foregroundStyle(.white.opacity(0.78))
            .accessibilityAddTraits(.isHeader)
    }

    private func iconButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticEngine.tap()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.52))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Hero (Endel-like: one calm statement, no underline / no hard chip)

    private var contextHero: some View {
        VStack(spacing: 10) {
            Text(lm.string(theme.currentContext.localizationKey))
                .font(.system(size: 34, weight: .light, design: .default))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.94))
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.currentContext)
                .animation(.easeInOut(duration: ThemeEngine.morphDuration), value: theme.blendProgress)

            if runtime.triggerType == .automatic {
                HStack(spacing: 8) {
                    PulsingDot()
                    Text(lm.string("ctx_auto").uppercased())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .tracking(1.8)
                        .foregroundStyle(theme.gradient.accentColor.opacity(0.9))
                }
                .accessibilityElement(children: .combine)
            } else if !runtime.audio.isUsingFileBed, runtime.audio.isPlaying {
                Text(lm.string("toast_demo_noise"))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom

    private var bottomControls: some View {
        VStack(spacing: 16) {
            if runtime.audio.isPlaying {
                TimerRing(
                    progress: ringProgress,
                    seconds: runtime.audio.remainingSeconds,
                    face: faceOverride
                )
                .padding(.bottom, 4)
                .onTapGesture {
                    HapticEngine.select()
                    let all = TimerFaceKind.allCases
                    if let current = faceOverride ?? TimerFaceKind.resolve(context: theme.currentContext),
                       let idx = all.firstIndex(of: current) {
                        faceOverride = all[(idx + 1) % all.count]
                    } else {
                        faceOverride = .hourglass
                    }
                }
                .onLongPressGesture {
                    HapticEngine.tap()
                    faceOverride = nil // back to context-auto
                }
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
            .padding(.top, 2)

            SoundMixerRow(
                sound: runtime.audio.primarySound ?? Sound.find("tokyo_rain")!,
                volume: Bindable(runtime.audio).primaryVolume,
                secondaryVolume: Bindable(runtime.audio).secondaryVolume,
                isPro: store.isPro || preferences.first?.isPro == true
            ) {
                runtime.showSounds = true
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
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
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
