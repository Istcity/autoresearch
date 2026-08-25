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
            if match.visitCount == 3, match.label == .unknown {
                pendingLabelPlace = match
                NotificationCenter.default.post(name: .placeNeedsLabel, object: match.id)
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
    }

    func setAutoStart(for place: UserPlace, enabled: Bool) {
        place.autoStartEnabled = enabled
    }

    func applyLabel(_ label: PlaceLabel, to place: UserPlace) {
        place.label = label
        place.defaultSoundID = label.suggestedContext.defaultSoundID
        pendingLabelPlace = nil
    }

    private func updateHomeConfidence(_ place: UserPlace, visit: CLVisit) {
        let hour = Calendar.current.component(.hour, from: visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate)
        let isNight = hour >= 23 || hour < 6
        place.homeConfidence = (place.homeConfidence * 0.8) + ((isNight ? 1.0 : 0.0) * 0.2)
        if place.homeConfidence > 0.7, place.label == .unknown {
            place.label = .home
        }
    }
}
