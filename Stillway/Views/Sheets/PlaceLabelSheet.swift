import SwiftUI

struct PlaceLabelSheet: View {
    @Environment(ContextEngine.self) private var runtime
    @Environment(\.lm) private var lm
    @Environment(\.dismiss) private var dismiss
    @State private var chosen: PlaceLabel?

    private let labels: [PlaceLabel] = [.home, .work, .library, .cafe, .gym, .other]

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            Text(String(format: lm.string("label_title"), runtime.pendingLabelPlace?.visitCount ?? 3))
                .font(.system(size: 22, weight: .regular))
                .multilineTextAlignment(.center)
            Text(lm.string("label_body"))
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(labels) { label in
                    Button {
                        choose(label)
                    } label: {
                        GlassCard {
                            VStack(spacing: 10) {
                                Image(systemName: label.sfSymbol)
                                    .font(.system(size: 28))
                                Text(lm.string(label.localizationKey))
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .frame(maxWidth: .infinity, minHeight: 88)
                            .overlay(alignment: .topTrailing) {
                                if chosen == label {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .hapticButton()
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
        .presentationBackground(.regularMaterial)
    }

    private func choose(_ label: PlaceLabel) {
        chosen = label
        HapticEngine.success()
        if let place = runtime.pendingLabelPlace {
            runtime.visitTracker?.applyLabel(label, to: place)
        }
        runtime.toast = lm.string("label_done")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            dismiss()
        }
    }
}
