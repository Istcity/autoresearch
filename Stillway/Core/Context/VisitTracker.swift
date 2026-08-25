import Foundation
import CoreLocation
import SwiftData
import Observation

@Observable
@MainActor
final class VisitTracker {
    var pendingLabelPlace: UserPlace?
    var toastMessage: String?

    func process(visit: CLVisit, places: [UserPlace], context: ModelContext) {
        let location = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        if let match = places.first(where: { $0.distance(to: location) < 100 }) {
            match.visitCount += 1
            match.lastSeen = visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate
            updateHomeConfidence(match, visit: visit)
            if match.visitCount == 3, match.label == nil {
                pendingLabelPlace = match
            }
            if match.visitCount >= 5, match.label != nil {
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

    func applyLabel(_ label: PlaceLabel, to place: UserPlace) {
        place.label = label
        place.defaultSoundID = label.suggestedContext.defaultSoundID
        toastMessage = nil
        pendingLabelPlace = nil
    }

    private func updateHomeConfidence(_ place: UserPlace, visit: CLVisit) {
        let hour = Calendar.current.component(.hour, from: visit.arrivalDate == Date.distantPast ? Date() : visit.arrivalDate)
        let isNight = hour >= 23 || hour < 6
        let sample = isNight ? 1.0 : 0.0
        place.homeConfidence = (place.homeConfidence * 0.8) + (sample * 0.2)
        if place.homeConfidence > 0.7, place.label == nil {
            place.label = .home
        }
    }
}
