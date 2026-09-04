import Foundation
import CoreLocation
import SwiftData

@MainActor
final class VisitTracker {
    var pendingLabelPlace: UserPlace?
    var toastMessage: String?
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func process(visit: CLVisit) {
        let places = (try? modelContext.fetch(FetchDescriptor<UserPlace>())) ?? []
        process(visit: visit, places: places, context: modelContext)
    }

    func process(visit: CLVisit, places: [UserPlace], context: ModelContext) {
        let coordinate = visit.coordinate
        if let match = places.first(where: { $0.distance(to: coordinate) < 100 }) {
            match.visitCount += 1
            match.lastSeen = visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate
            updateHomeConfidence(match, visit: visit)
            updateWorkConfidence(match, visit: visit)
            if match.visitCount == 3, match.label == .unknown {
                pendingLabelPlace = match
                NotificationCenter.default.post(name: .placeNeedsLabel, object: match.id)
                NotificationScheduler.shared.suggestPlaceLabel(
                    body: NSLocalizedString("notif_place_label", comment: "")
                )
            }
            if match.visitCount >= 5, match.label != .unknown {
                match.autoStartEnabled = true
            }
        } else {
            let place = UserPlace(
                latitude: visit.coordinate.latitude,
                longitude: visit.coordinate.longitude,
                visitCount: 1,
                lastSeen: visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate
            )
            context.insert(place)
        }
        try? context.save()
    }

    func setAutoStart(for place: UserPlace, enabled: Bool) {
        place.autoStartEnabled = enabled
        try? modelContext.save()
    }

    func applyLabel(_ label: PlaceLabel, to place: UserPlace) {
        place.label = label
        place.defaultSoundID = label.suggestedContext.defaultSoundID
        if label == .home {
            place.homeConfidence = max(place.homeConfidence, 0.85)
        }
        pendingLabelPlace = nil
        try? modelContext.save()
    }

    private func updateHomeConfidence(_ place: UserPlace, visit: CLVisit) {
        let hour = Calendar.current.component(.hour, from: visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate)
        let isNight = hour >= 22 || hour < 7
        place.homeConfidence = (place.homeConfidence * 0.8) + ((isNight ? 1.0 : 0.0) * 0.2)
        if place.homeConfidence > 0.7, place.label == .unknown {
            place.label = .home
            place.defaultSoundID = PlaceLabel.home.suggestedContext.defaultSoundID
        }
    }

    private func updateWorkConfidence(_ place: UserPlace, visit: CLVisit) {
        let hour = Calendar.current.component(.hour, from: visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate)
        let isWorkHours = (9...18).contains(hour)
        // Soft signal only — do not auto-label work (too aggressive); boost confidence for UI.
        if isWorkHours, place.label == .unknown, place.visitCount >= 4 {
            place.homeConfidence = max(0, place.homeConfidence - 0.05)
        }
    }
}
