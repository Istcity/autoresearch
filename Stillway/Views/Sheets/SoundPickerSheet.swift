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
                LazyVStack(alignment: .leading, spacing: 24) {
                    binauralSection
                    ForEach(grouped, id: \.context) { group in
                        soundGroup(group.context, sounds: group.sounds)
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

    @ViewBuilder
    private var binauralSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.string("binaural_title").uppercased())
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.45))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(BinauralTone.allCases) { tone in
                        binauralChip(tone)
                    }
                }
            }
        }
    }

    private func binauralChip(_ tone: BinauralTone) -> some View {
        let selected = runtime.audio.binauralTone == tone
        return Button {
            runtime.audio.setBinauralTone(tone)
            HapticEngine.select()
        } label: {
            Text(lm.string(tone.localizationKey))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(selected ? .black : .white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? theme.gradient.accentColor : Color.white.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }

    private func soundGroup(_ context: AppContext, sounds: [Sound]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lm.string(context.localizationKey).uppercased())
                .font(.system(size: 13, weight: .medium))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.45))
            ForEach(sounds) { sound in
                soundRow(sound)
            }
        }
    }

    private func soundRow(_ sound: Sound) -> some View {
        let locked = !sound.isFree && !store.isPro
        let selected = runtime.audio.primarySound?.id == sound.id
        return Button {
            select(sound, locked: locked)
        } label: {
            soundRowLabel(sound, locked: locked, selected: selected)
        }
        .buttonStyle(.plain)
    }

    private func select(_ sound: Sound, locked: Bool) {
        if locked {
            runtime.showSettings = true
            dismiss()
            return
        }
        let prefs = try? modelContext.fetch(FetchDescriptor<UserPreferences>()).first
        runtime.selectSound(sound, isPro: store.isPro, preferences: prefs)
        HapticEngine.select()
        dismiss()
    }

    private func soundRowLabel(_ sound: Sound, locked: Bool, selected: Bool) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Image(systemName: sound.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.gradient.accentColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
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
                trailingIcon(locked: locked, selected: selected)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(selected ? theme.gradient.accentColor : .clear, lineWidth: 1.5)
        }
        .scaleEffect(selected ? 1.03 : 1)
    }

    @ViewBuilder
    private func trailingIcon(locked: Bool, selected: Bool) -> some View {
        if locked {
            Image(systemName: "lock.fill")
                .foregroundStyle(theme.gradient.accentColor.opacity(0.8))
        } else if selected {
            Image(systemName: "checkmark")
                .foregroundStyle(theme.gradient.accentColor)
        }
    }
}
