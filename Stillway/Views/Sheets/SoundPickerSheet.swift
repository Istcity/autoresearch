import SwiftUI
import SwiftData

struct SoundPickerSheet: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(ThemeEngine.self) private var theme
    @Environment(PurchaseManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(grouped, id: \.context) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(lm.string(group.context.localizationKey).uppercased())
                                .font(.system(size: 13, weight: .medium))
                                .tracking(0.5)
                                .foregroundStyle(.white.opacity(0.45))
                            ForEach(group.sounds) { sound in
                                soundRow(sound)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.black.opacity(0.2))
            .navigationTitle(lm.string("sounds_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.string("btn_done")) { dismiss() }
                }
            }
        }
        .presentationBackground(.regularMaterial)
    }

    private var grouped: [(context: AppContext, sounds: [Sound])] {
        [.commute, .focus, .reset, .sleep].map { ctx in
            (ctx, Sound.sounds(for: ctx))
        }
    }

    private func soundRow(_ sound: Sound) -> some View {
        let locked = !sound.isFree && !store.isPro
        let selected = runtime.audio.primarySound?.id == sound.id
        return Button {
            if locked {
                runtime.showSettings = true
                dismiss()
            } else {
                let prefs = try? modelContext.fetch(FetchDescriptor<UserPreferences>()).first
                runtime.selectSound(sound, isPro: store.isPro, preferences: prefs)
                HapticEngine.select()
                dismiss()
            }
        } label: {
            GlassCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(lm.string(sound.localizationKey))
                                .font(.system(size: 17))
                                .foregroundStyle(.white)
                            Text(sound.region.flag)
                        }
                        if locked {
                            Text(lm.string("mixer_locked"))
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    Spacer()
                    if locked {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(theme.gradient.accentColor.opacity(0.8))
                    } else if selected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(theme.gradient.accentColor)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? theme.gradient.accentColor : .clear, lineWidth: 1.5)
            }
            .scaleEffect(selected ? 1.03 : 1)
        }
        .buttonStyle(.plain)
    }
}
