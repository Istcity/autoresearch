import Foundation
import CoreLocation

final class GeofenceManager {
    static let maxActive = 18

    var onTransitEntry: ((Station) -> Void)?
    var onTransitExit: ((Station) -> Void)?
    var onEnter: ((Station) -> Void)? {
        get { onTransitEntry }
        set { onTransitEntry = newValue }
    }
    var onExit: ((Station) -> Void)? {
        get { onTransitExit }
        set { onTransitExit = newValue }
    }

    private(set) var activeStationIDs: [String] = []
    private var stationsByID: [String: Station] = [:]
    private let locationManager = LocationManager.shared

    func setup() {
        locationManager.onRegionEnter = { [weak self] identifier in
            guard let station = self?.stationsByID[identifier] else { return }
            self?.onTransitEntry?(station)
        }
        locationManager.onRegionExit = { [weak self] identifier in
            guard let station = self?.stationsByID[identifier] else { return }
            self?.onTransitExit?(station)
        }
    }

    func refresh(near coordinate: CLLocationCoordinate2D) {
        let next = StationDatabase.shared.nearest(to: coordinate, limit: Self.maxActive)
        refresh(around: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), stations: next)
    }

    func refresh(around location: CLLocation, stations: [Station]) {
        let unique = Array(stations.prefix(Self.maxActive))
        let nextIDs = Set(unique.map(\.id))
        let current = Set(activeStationIDs)

        for id in current.subtracting(nextIDs) {
            let region = CLCircularRegion(
                center: stationsByID[id]?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                radius: stationsByID[id]?.geofenceRadius ?? 80,
                identifier: id
            )
            locationManager.stopMonitoring(region: region)
            stationsByID[id] = nil
        }

        for station in unique where !current.contains(station.id) {
            let region = CLCircularRegion(center: station.coordinate, radius: station.geofenceRadius, identifier: station.id)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(region: region)
            stationsByID[station.id] = station
        }
        activeStationIDs = unique.map(\.id)
    }

    func clearAll() {
        locationManager.stopAllGeofences()
        stationsByID.removeAll()
        activeStationIDs = []
    }
}
