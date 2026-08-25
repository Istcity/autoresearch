import Foundation
import CoreLocation
import GRDB

final class StationDatabase: Sendable {
    let stations: [Station]
    private let grid: [GridKey: [Int]]
    private let cellSize = 0.05

    init(stations: [Station]) {
        self.stations = stations
        var grid: [GridKey: [Int]] = [:]
        for (index, station) in stations.enumerated() {
            let key = GridKey(lat: station.latitude, lon: station.longitude, cellSize: 0.05)
            grid[key, default: []].append(index)
        }
        self.grid = grid
    }

    static func loadFromBundle() -> StationDatabase {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Station].self, from: data) else {
            return StationDatabase(stations: Station.sample)
        }
        let database = StationDatabase(stations: decoded)
        database.warmSQLiteCache()
        return database
    }

    /// Offline SQLite cache (GRDB) so the station set can be queried without re-parsing JSON.
    func warmSQLiteCache() {
        let fileManager = FileManager.default
        guard let directory = try? fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        let path = directory.appendingPathComponent("stillway-stations.sqlite").path
        guard let queue = try? DatabaseQueue(path: path) else { return }
        try? queue.write { db in
            try db.create(table: "station", ifNotExists: true) { table in
                table.column("id", .text).primaryKey()
                table.column("name", .text).notNull()
                table.column("city", .text).notNull()
                table.column("country", .text).notNull()
                table.column("latitude", .double).notNull()
                table.column("longitude", .double).notNull()
                table.column("transitType", .text).notNull()
            }
            try db.execute(sql: "DELETE FROM station")
            for station in stations {
                try db.execute(
                    sql: """
                    INSERT INTO station (id, name, city, country, latitude, longitude, transitType)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    arguments: [
                        station.id, station.name, station.city, station.country,
                        station.latitude, station.longitude, station.transitType.rawValue
                    ]
                )
            }
        }
    }

    func nearest(to location: CLLocation, limit: Int = 18) -> [Station] {
        let originKey = GridKey(lat: location.coordinate.latitude, lon: location.coordinate.longitude, cellSize: cellSize)
        var candidates: [Int] = []
        for dLat in -2...2 {
            for dLon in -2...2 {
                let key = GridKey(latIndex: originKey.latIndex + dLat, lonIndex: originKey.lonIndex + dLon)
                if let bucket = grid[key] {
                    candidates.append(contentsOf: bucket)
                }
            }
        }
        if candidates.isEmpty {
            candidates = Array(stations.indices)
        }
        return candidates
            .map { stations[$0] }
            .sorted { $0.distance(to: location) < $1.distance(to: location) }
            .prefix(limit)
            .map { $0 }
    }
}

private struct GridKey: Hashable, Sendable {
    let latIndex: Int
    let lonIndex: Int

    init(lat: Double, lon: Double, cellSize: Double) {
        self.latIndex = Int(floor(lat / cellSize))
        self.lonIndex = Int(floor(lon / cellSize))
    }

    init(latIndex: Int, lonIndex: Int) {
        self.latIndex = latIndex
        self.lonIndex = lonIndex
    }
}

extension Station {
    static let sample: [Station] = [
        Station(id: "jp-tokyo-ginza", name: "Ginza", city: "Tokyo", country: "JP", latitude: 35.6717, longitude: 139.7649, transitType: .metro),
        Station(id: "jp-tokyo-shibuya", name: "Shibuya", city: "Tokyo", country: "JP", latitude: 35.6580, longitude: 139.7016, transitType: .rail),
        Station(id: "jp-tokyo-shinjuku", name: "Shinjuku", city: "Tokyo", country: "JP", latitude: 35.6909, longitude: 139.7003, transitType: .rail),
        Station(id: "jp-kyoto-kyoto", name: "Kyoto", city: "Kyoto", country: "JP", latitude: 34.9858, longitude: 135.7588, transitType: .rail),
        Station(id: "us-nyc-timesq", name: "Times Square-42 St", city: "New York", country: "US", latitude: 40.7559, longitude: -73.9871, transitType: .metro),
        Station(id: "us-nyc-union", name: "Union Square", city: "New York", country: "US", latitude: 40.7359, longitude: -73.9906, transitType: .metro),
        Station(id: "us-sf-montgomery", name: "Montgomery", city: "San Francisco", country: "US", latitude: 37.7894, longitude: -122.4011, transitType: .rail),
        Station(id: "fr-paris-chatelet", name: "Châtelet", city: "Paris", country: "FR", latitude: 48.8583, longitude: 2.3475, transitType: .metro),
        Station(id: "fr-paris-nation", name: "Nation", city: "Paris", country: "FR", latitude: 48.8483, longitude: 2.3958, transitType: .metro),
        Station(id: "gb-london-kingsx", name: "King's Cross St Pancras", city: "London", country: "GB", latitude: 51.5308, longitude: -0.1238, transitType: .metro),
        Station(id: "gb-london-oxford", name: "Oxford Circus", city: "London", country: "GB", latitude: 51.5152, longitude: -0.1418, transitType: .metro),
        Station(id: "tr-ist-taksim", name: "Taksim", city: "Istanbul", country: "TR", latitude: 41.0369, longitude: 28.9850, transitType: .metro),
        Station(id: "tr-ist-kadikoy", name: "Kadıköy", city: "Istanbul", country: "TR", latitude: 40.9909, longitude: 29.0290, transitType: .ferry),
        Station(id: "tr-ist-mecidiyekoy", name: "Mecidiyeköy", city: "Istanbul", country: "TR", latitude: 41.0670, longitude: 28.9870, transitType: .metro),
        Station(id: "tr-ank-kizilay", name: "Kızılay", city: "Ankara", country: "TR", latitude: 39.9208, longitude: 32.8541, transitType: .metro)
    ]
}
