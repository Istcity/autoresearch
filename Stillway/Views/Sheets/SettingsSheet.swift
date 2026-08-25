import SwiftUI
import SwiftData

struct SettingsSheet: View {
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(LocalizationManager.self) private var lm
    @Environment(ThemeEngine.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @Query private var preferences: [UserPreferences]

    var body: some View {
        NavigationStack {
            List {
                generalSection
                languageSection
                proSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(lm.string("settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.string("btn_done")) { dismiss() }
                }
            }
        }
        .presentationBackground(.regularMaterial)
        .onAppear { ensurePreferences() }
    }

    @Environment(\.modelContext) private var modelContext

    private var prefs: UserPreferences? { preferences.first }

    private var generalSection: some View {
        Section(lm.string("settings_general")) {
            Toggle(lm.string("settings_context_detection"), isOn: bind(\.contextDetectionEnabled))
            Toggle(lm.string("settings_sleep_mode"), isOn: bind(\.sleepModeEnabled))
            Picker(lm.string("settings_sleep_start"), selection: bindHour()) {
                ForEach(20...24, id: \.self) { hour in
                    Text(String(format: "%02d:00", hour == 24 ? 0 : hour)).tag(hour == 24 ? 0 : hour)
                }
            }
            Toggle(lm.string("settings_haptic_breath"), isOn: bind(\.hapticBreathingEnabled))
                .disabled(!runtime.breathing.isSupported)
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var languageSection: some View {
        Section {
            Picker(lm.string("settings_language"), selection: Bindable(runtime.localization).selectedLanguage) {
                ForEach(LanguageCode.allCases) { code in
                    Text(code.displayName).tag(code.rawValue)
                }
            }
            .onChange(of: runtime.localization.selectedLanguage) { _, newValue in
                prefs?.selectedLanguage = newValue
            }
            Text(lm.string("settings_language_note"))
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.5))
        } header: {
            Text(lm.string("settings_language"))
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var proSection: some View {
        Section(lm.string("settings_pro")) {
            if runtime.store.isPro {
                Label("Stillway Pro", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(theme.gradient.accentColor)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(proFeatures, id: \.self) { key in
                        Label(lm.string(key), systemImage: "sparkle")
                            .font(.system(size: 15))
                    }
                }
                Button {
                    Task { await runtime.store.purchase() }
                } label: {
                    PillButtonLabel(title: "\(lm.string("pro_cta"))  \(lm.string("pro_price"))")
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .hapticButton()
                Button(lm.string("btn_restore")) {
                    Task { await runtime.store.restore() }
                }
                .foregroundStyle(.white.opacity(0.7))
            }
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var aboutSection: some View {
        Section(lm.string("settings_about")) {
            HStack {
                Text(lm.string("settings_version"))
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.white.opacity(0.5))
                    .font(.system(.body, design: .monospaced))
            }
            Text(lm.string("privacy_body"))
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.55))
            Link(lm.string("settings_privacy"), destination: URL(string: "https://stillway.app/privacy")!)
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private var proFeatures: [String] {
        ["pro_feature_sounds", "pro_feature_mix", "pro_feature_autostart", "pro_feature_places", "pro_feature_journey", "pro_feature_haptics", "pro_feature_sleep"]
    }

    private func ensurePreferences() {
        if preferences.isEmpty {
            modelContext.insert(UserPreferences())
        }
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<UserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { prefs?[keyPath: keyPath] ?? false },
            set: { prefs?[keyPath: keyPath] = $0 }
        )
    }

    private func bindHour() -> Binding<Int> {
        Binding(
            get: {
                let hour = prefs?.sleepStartHour ?? 22
                return hour == 24 ? 0 : hour
            },
            set: { prefs?.sleepStartHour = $0 == 0 ? 24 : $0 }
        )
    }
}
