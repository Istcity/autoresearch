import Foundation
import CoreLocation

enum TransitType: String, Codable, Sendable {
    case metro = "METRO"
    case rail = "RAIL"
    case tram = "TRAM"
    case ferry = "FERRY"
    case bus = "BUS"
    case brt = "BRT"
}

struct Station: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let nameEn: String
    let lat: Double
    let lon: Double
    let country: String
    let city: String
    let type: TransitType
    let lines: [String]

    var latitude: Double { lat }
    var longitude: Double { lon }
    var transitType: TransitType { type }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var geofenceRadius: Double {
        switch type {
        case .metro, .tram: return 80
        case .rail, .ferry: return 150
        case .bus, .brt: return 60
        }
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        CLLocation(latitude: lat, longitude: lon).distance(from: location)
    }

    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: lat, longitude: lon)
            .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    enum CodingKeys: String, CodingKey {
        case id, name, nameEn = "name_en", lat, lon, country, city, type, lines
    }
}
