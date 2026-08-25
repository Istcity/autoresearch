import SwiftUI
import SwiftData

struct PlacesSheet: View {
    @Environment(LocalizationManager.self) private var lm
    @Environment(StillwayRuntime.self) private var runtime
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \UserPlace.visitCount, order: .reverse) private var places: [UserPlace]

    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty {
                    ContentUnavailableView(
                        lm.string("places_title"),
                        systemImage: "location.slash",
                        description: Text(lm.string("places_empty"))
                    )
                } else {
                    List(places) { place in
                        HStack(spacing: 14) {
                            Image(systemName: place.label?.symbolName ?? "mappin")
                                .font(.system(size: 20))
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.label.map { lm.string($0.localizationKey) } ?? place.customName ?? "—")
                                    .font(.system(size: 17))
                                Text("\(place.visitCount) \(lm.string("place_visits"))")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                            Spacer()
                            if place.autoStartEnabled {
                                PulsingDot()
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                        .onTapGesture {
                            runtime.visitTracker.pendingLabelPlace = place
                            runtime.showPlaceLabel = true
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(lm.string("places_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lm.string("btn_done")) { dismiss() }
                }
            }
        }
        .presentationBackground(.regularMaterial)
    }
}
