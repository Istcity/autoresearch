import Foundation
import CoreLocation

enum TransitType: String, Codable, Sendable {
    case metro
    case rail
    case tram
    case ferry
}

struct Station: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    let transitType: TransitType

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var geofenceRadius: Double {
        switch transitType {
        case .metro, .tram: return 80
        case .rail, .ferry: return 150
        }
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: location)
    }
}
