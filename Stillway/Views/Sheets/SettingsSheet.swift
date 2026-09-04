import SwiftUI
import SwiftData
import CoreLocation
import CoreMotion
import UserNotifications
import UIKit

struct SettingsSheet: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme
    @Environment(PurchaseManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var preferences: [UserPreferences]
    @State private var permissionSnapshot: PermissionBootstrap.Snapshot?
    @State private var isRefreshingPermissions = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    section(lm.string("settings_general")) {
                        toggle(lm.string("settings_context"), subtitle: lm.string("settings_context_desc"), keyPath: \.contextDetectionEnabled)
                        toggle(lm.string("settings_sleep"), subtitle: lm.string("settings_sleep_desc"), keyPath: \.sleepModeEnabled)
                        DatePicker(
                            lm.string("settings_sleep_start"),
                            selection: sleepStartDate,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(theme.gradient.accentColor)
                        DatePicker(
                            lm.string("settings_sleep_end"),
                            selection: sleepEndDate,
                            displayedComponents: .hourAndMinute
                        )
                        .tint(theme.gradient.accentColor)
                        toggle(lm.string("settings_haptic"), subtitle: lm.string("settings_haptic_desc"), keyPath: \.hapticBreathingEnabled)
                            .disabled(!runtime.breathing.isSupported)
                    }

                    section(lm.string("settings_permissions")) {
                        permissionRow(
                            title: lm.string("settings_perm_location"),
                            status: locationStatusText,
                            needsSettings: locationNeedsSettings
                        )
                        permissionRow(
                            title: lm.string("settings_perm_motion"),
                            status: motionStatusText,
                            needsSettings: motionNeedsSettings
                        )
                        permissionRow(
                            title: lm.string("settings_perm_notifications"),
                            status: notificationStatusText,
                            needsSettings: notificationNeedsSettings
                        )
                        Button(lm.string("settings_open_settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.gradient.accentColor)
                        Button(lm.string("settings_request_permissions")) {
                            Task {
                                isRefreshingPermissions = true
                                await runtime.requestStartupPermissions()
                                await refreshPermissions()
                                isRefreshingPermissions = false
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        if isRefreshingPermissions {
                            ProgressView()
                        }
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
        .onAppear {
            ensurePreferences()
            Task { await refreshPermissions() }
        }
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

    private var sleepStartDate: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: prefs?.sleepStartHour ?? 22, minute: 0, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                prefs?.sleepStartHour = Calendar.current.component(.hour, from: date)
            }
        )
    }

    private var sleepEndDate: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: prefs?.sleepEndHour ?? 7, minute: 0, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                prefs?.sleepEndHour = Calendar.current.component(.hour, from: date)
            }
        )
    }

    private var locationStatusText: String {
        switch permissionSnapshot?.locationStatus ?? runtime.location.authStatus {
        case .authorizedAlways: return lm.string("perm_status_always")
        case .authorizedWhenInUse: return lm.string("perm_status_when_in_use")
        case .denied, .restricted: return lm.string("perm_status_denied")
        case .notDetermined: return lm.string("perm_status_not_determined")
        @unknown default: return lm.string("perm_status_unknown")
        }
    }

    private var motionStatusText: String {
        switch permissionSnapshot?.motionStatus ?? CMMotionActivityManager.authorizationStatus() {
        case .authorized: return lm.string("perm_status_allowed")
        case .denied, .restricted: return lm.string("perm_status_denied")
        case .notDetermined: return lm.string("perm_status_not_determined")
        @unknown default: return lm.string("perm_status_unknown")
        }
    }

    private var notificationStatusText: String {
        if permissionSnapshot?.notificationsAuthorized == true {
            return lm.string("perm_status_allowed")
        }
        if prefs?.didRequestNotificationPermission == true {
            return lm.string("perm_status_denied")
        }
        return lm.string("perm_status_not_determined")
    }

    private var locationNeedsSettings: Bool {
        let status = permissionSnapshot?.locationStatus ?? runtime.location.authStatus
        return status == .denied || status == .restricted || status == .authorizedWhenInUse
    }

    private var motionNeedsSettings: Bool {
        let status = permissionSnapshot?.motionStatus ?? CMMotionActivityManager.authorizationStatus()
        return status == .denied || status == .restricted
    }

    private var notificationNeedsSettings: Bool {
        prefs?.didRequestNotificationPermission == true && permissionSnapshot?.notificationsAuthorized != true
    }

    private func permissionRow(title: String, status: String, needsSettings: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                Text(status)
                    .font(.system(size: 13))
                    .foregroundStyle(needsSettings ? Color.orange.opacity(0.9) : Color.white.opacity(0.45))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: needsSettings ? "exclamationmark.circle" : "checkmark.circle.fill")
                .foregroundStyle(needsSettings ? Color.orange : Color.green.opacity(0.85))
        }
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

    private func refreshPermissions() async {
        let snap = await PermissionBootstrap.currentSnapshot()
        permissionSnapshot = snap
        prefs?.lastKnownLocationAuthRaw = Int(snap.locationStatus.rawValue)
        prefs?.lastKnownMotionAuthRaw = Int(snap.motionStatus.rawValue)
        prefs?.lastKnownNotificationAuthorized = snap.notificationsAuthorized
        try? modelContext.save()
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<UserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { prefs?[keyPath: keyPath] ?? false },
            set: { prefs?[keyPath: keyPath] = $0 }
        )
    }
}
