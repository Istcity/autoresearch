import Foundation
import CoreLocation
import Observation

@Observable
@MainActor
final class GeofenceManager: NSObject {
    static let maxActive = 18

    private let manager = CLLocationManager()
    private(set) var activeStationIDs: [String] = []
    var onEnter: ((Station) -> Void)?
    var onExit: ((Station) -> Void)?

    private var stationsByRegion: [String: Station] = [:]

    override init() {
        super.init()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = true
    }

    func refresh(around location: CLLocation, stations: [Station]) {
        let ranked = stations
            .map { ($0, $0.distance(to: location)) }
            .sorted { $0.1 < $1.1 }

        var unique: [Station] = []
        var occupied = Set<String>()
        for (station, _) in ranked {
            let key = "\(Int(station.latitude * 4000)):\(Int(station.longitude * 4000))"
            if occupied.contains(key) { continue }
            occupied.insert(key)
            unique.append(station)
            if unique.count >= Self.maxActive { break }
        }

        let nextIDs = Set(unique.map(\.id))
        let currentIDs = Set(activeStationIDs)

        for id in currentIDs.subtracting(nextIDs) {
            manager.stopMonitoring(for: CLCircularRegion(
                center: stationsByRegion[id]?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                radius: 80,
                identifier: id
            ))
            stationsByRegion[id] = nil
        }

        for station in unique where !currentIDs.contains(station.id) {
            let region = CLCircularRegion(center: station.coordinate, radius: station.geofenceRadius, identifier: station.id)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
            stationsByRegion[station.id] = station
        }

        activeStationIDs = unique.map(\.id)
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            if let station = stationsByRegion[region.identifier] {
                onEnter?(station)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Task { @MainActor in
            if let station = stationsByRegion[region.identifier] {
                onExit?(station)
            }
        }
    }
}
