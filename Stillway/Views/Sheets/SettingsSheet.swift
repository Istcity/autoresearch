import SwiftUI
import SwiftData

struct SettingsSheet: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme
    @Environment(PurchaseManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    section(lm.string("settings_general")) {
                        toggle(lm.string("settings_context"), subtitle: lm.string("settings_context_desc"), keyPath: \.contextDetectionEnabled)
                        toggle(lm.string("settings_sleep"), subtitle: lm.string("settings_sleep_desc"), keyPath: \.sleepModeEnabled)
                        DatePicker(
                            lm.string("settings_sleep_start"),
                            selection: sleepDate,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(theme.gradient.accentColor)
                        toggle(lm.string("settings_haptic"), subtitle: lm.string("settings_haptic_desc"), keyPath: \.hapticBreathingEnabled)
                            .disabled(!runtime.breathing.isSupported)
                    }

                    section(lm.string("settings_language")) {
                        Picker(lm.string("settings_language"), selection: languageBinding) {
                            ForEach(LanguageCode.allCases) { code in
                                Text("\(code.flag)  \(code.displayName)").tag(code.rawValue)
                            }
                        }
                        .onChange(of: lm.currentLanguage) { _, newValue in
                            prefs?.selectedLanguage = newValue.rawValue
                        }
                        Text(lm.string("settings_language_note"))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    section(lm.string("settings_pro_section")) {
                        if store.isPro {
                            Label(lm.string("pro_active"), systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        } else {
                            ForEach(1...6, id: \.self) { index in
                                Label(lm.string("settings_pro_feature_\(index)"), systemImage: "sparkle")
                                    .font(.system(size: 15))
                            }
                            PillButton(label: lm.string("settings_pro_btn")) {
                                Task { await store.purchase() }
                            }
                            Button(lm.string("settings_restore")) {
                                Task { await store.restorePurchases() }
                            }
                            .foregroundStyle(.white.opacity(0.7))
                            if store.isLoading {
                                ProgressView()
                            }
                            if let error = store.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                        }
                    }

                    section(lm.string("settings_about")) {
                        HStack {
                            Text(lm.string("settings_version"))
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(.system(.body, design: .monospaced))
                        }
                        Text(lm.string("privacy_body"))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.55))
                        Link(lm.string("settings_privacy"), destination: URL(string: "https://stillway.app/privacy")!)
                    }
                }
                .padding(20)
            }
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
        .onChange(of: store.isPro) { _, isPro in
            prefs?.isPro = isPro
        }
    }

    private var languageBinding: Binding<String> {
        Binding(
            get: { lm.currentLanguage.rawValue },
            set: { lm.currentLanguage = LanguageCode(rawValue: $0) ?? .en }
        )
    }

    private var prefs: UserPreferences? { preferences.first }

    private var sleepDate: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: prefs?.sleepStartHour ?? 22, minute: 0, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                prefs?.sleepStartHour = Calendar.current.component(.hour, from: date)
            }
        )
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.45))
            content()
        }
    }

    private func toggle(_ title: String, subtitle: String, keyPath: ReferenceWritableKeyPath<UserPreferences, Bool>) -> some View {
        Toggle(isOn: bind(keyPath)) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .tint(theme.gradient.accentColor)
    }

    private func ensurePreferences() {
        if preferences.isEmpty { modelContext.insert(UserPreferences()) }
        if store.isPro { prefs?.isPro = true }
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<UserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { prefs?[keyPath: keyPath] ?? false },
            set: { prefs?[keyPath: keyPath] = $0 }
        )
    }
}
