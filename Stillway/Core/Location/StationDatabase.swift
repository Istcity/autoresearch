import Foundation
import CoreLocation
import GRDB

final class StationDatabase: @unchecked Sendable {
    static let shared = StationDatabase.load()

    let stations: [Station]
    private let grid: [GridKey: [Int]]
    private let cellSize = 0.01

    var count: Int { stations.count }

    init(stations: [Station]) {
        self.stations = stations
        var grid: [GridKey: [Int]] = [:]
        for (index, station) in stations.enumerated() {
            grid[GridKey(lat: station.lat, lon: station.lon, cellSize: 0.01), default: []].append(index)
        }
        self.grid = grid
        warmSQLiteCache()
    }

    static func loadFromBundle() -> StationDatabase { shared }

    static func load() -> StationDatabase {
        if let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([Station].self, from: data),
           !decoded.isEmpty {
            return StationDatabase(stations: decoded)
        }
        return StationDatabase(stations: Station.sample)
    }

    func station(id: String) -> Station? {
        stations.first { $0.id == id }
    }

    func nearest(to coordinate: CLLocationCoordinate2D, limit: Int = 18, maxMeters: Double = 50_000) -> [Station] {
        nearest(to: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), limit: limit, maxMeters: maxMeters)
    }

    func nearest(to location: CLLocation, limit: Int = 18, maxMeters: Double = 50_000) -> [Station] {
        let origin = GridKey(lat: location.coordinate.latitude, lon: location.coordinate.longitude, cellSize: cellSize)
        var candidates: [Int] = []
        for dLat in -2...2 {
            for dLon in -2...2 {
                if let bucket = grid[GridKey(latIndex: origin.latIndex + dLat, lonIndex: origin.lonIndex + dLon)] {
                    candidates.append(contentsOf: bucket)
                }
            }
        }
        if candidates.isEmpty { candidates = Array(stations.indices) }
        return candidates
            .map { stations[$0] }
            .map { ($0, $0.distance(to: location)) }
            .filter { $0.1 <= maxMeters }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map(\.0)
    }

    func warmSQLiteCache() {
        guard let directory = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true),
              let queue = try? DatabaseQueue(path: directory.appendingPathComponent("stillway-stations.sqlite").path) else {
            return
        }
        try? queue.write { db in
            try db.create(table: "station", ifNotExists: true) { table in
                table.column("id", .text).primaryKey()
                table.column("name", .text).notNull()
                table.column("name_en", .text).notNull()
                table.column("lat", .double).notNull()
                table.column("lon", .double).notNull()
                table.column("country", .text).notNull()
                table.column("city", .text).notNull()
                table.column("type", .text).notNull()
            }
            try db.execute(sql: "DELETE FROM station")
            for station in stations {
                try db.execute(
                    sql: "INSERT INTO station (id, name, name_en, lat, lon, country, city, type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [station.id, station.name, station.nameEn, station.lat, station.lon, station.country, station.city, station.type.rawValue]
                )
            }
        }
    }
}

private struct GridKey: Hashable, Sendable {
    let latIndex: Int
    let lonIndex: Int

    init(lat: Double, lon: Double, cellSize: Double) {
        latIndex = Int(floor(lat / cellSize))
        lonIndex = Int(floor(lon / cellSize))
    }

    init(latIndex: Int, lonIndex: Int) {
        self.latIndex = latIndex
        self.lonIndex = lonIndex
    }
}

extension Station {
    static let sample: [Station] = [
        Station(id: "jp-tokyo-shibuya", name: "渋谷", nameEn: "Shibuya", lat: 35.6580, lon: 139.7016, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "G"]),
        Station(id: "jp-tokyo-shinjuku", name: "新宿", nameEn: "Shinjuku", lat: 35.6909, lon: 139.7003, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "M"]),
        Station(id: "jp-tokyo-ikebukuro", name: "池袋", nameEn: "Ikebukuro", lat: 35.7295, lon: 139.7109, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "F"]),
        Station(id: "jp-tokyo-tokyo", name: "東京", nameEn: "Tokyo", lat: 35.6812, lon: 139.7671, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "M"]),
        Station(id: "jp-tokyo-ueno", name: "上野", nameEn: "Ueno", lat: 35.7138, lon: 139.7773, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "H"]),
        Station(id: "jp-tokyo-akihabara", name: "秋葉原", nameEn: "Akihabara", lat: 35.6984, lon: 139.7731, country: "JP", city: "Tokyo", type: .rail, lines: ["JY", "H"]),
        Station(id: "jp-tokyo-otemachi", name: "大手町", nameEn: "Otemachi", lat: 35.6846, lon: 139.7660, country: "JP", city: "Tokyo", type: .metro, lines: ["M", "C"]),
        Station(id: "jp-osaka-osaka", name: "大阪", nameEn: "Osaka", lat: 34.7024, lon: 135.4959, country: "JP", city: "Osaka", type: .rail, lines: ["JR"]),
        Station(id: "jp-osaka-umeda", name: "梅田", nameEn: "Umeda", lat: 34.7055, lon: 135.4983, country: "JP", city: "Osaka", type: .metro, lines: ["M"]),
        Station(id: "us-nyc-timesq", name: "Times Sq-42 St", nameEn: "Times Square", lat: 40.7559, lon: -73.9871, country: "US", city: "New York", type: .metro, lines: ["1", "2", "N", "Q"]),
        Station(id: "us-nyc-grandcentral", name: "Grand Central-42 St", nameEn: "Grand Central", lat: 40.7527, lon: -73.9772, country: "US", city: "New York", type: .metro, lines: ["4", "5", "6", "7"]),
        Station(id: "us-nyc-union", name: "14 St-Union Sq", nameEn: "Union Square", lat: 40.7359, lon: -73.9906, country: "US", city: "New York", type: .metro, lines: ["L", "N", "Q"]),
        Station(id: "us-nyc-penn", name: "34 St-Penn Station", nameEn: "Penn Station", lat: 40.7506, lon: -73.9935, country: "US", city: "New York", type: .metro, lines: ["1", "2", "3", "A"]),
        Station(id: "us-nyc-fulton", name: "Fulton St", nameEn: "Fulton", lat: 40.7094, lon: -74.0083, country: "US", city: "New York", type: .metro, lines: ["A", "C", "2", "3"]),
        Station(id: "fr-paris-chatelet", name: "Châtelet", nameEn: "Chatelet", lat: 48.8583, lon: 2.3475, country: "FR", city: "Paris", type: .metro, lines: ["1", "4", "7", "11", "14"]),
        Station(id: "fr-paris-garedunord", name: "Gare du Nord", nameEn: "Gare du Nord", lat: 48.8809, lon: 2.3553, country: "FR", city: "Paris", type: .rail, lines: ["4", "5", "B", "D"]),
        Station(id: "fr-paris-stgermain", name: "Saint-Germain-des-Prés", nameEn: "St-Germain", lat: 48.8534, lon: 2.3338, country: "FR", city: "Paris", type: .metro, lines: ["4"]),
        Station(id: "fr-paris-montparnasse", name: "Montparnasse-Bienvenüe", nameEn: "Montparnasse", lat: 48.8435, lon: 2.3219, country: "FR", city: "Paris", type: .metro, lines: ["4", "6", "12", "13"]),
        Station(id: "gb-london-kingsx", name: "King's Cross St Pancras", nameEn: "King's Cross", lat: 51.5308, lon: -0.1238, country: "GB", city: "London", type: .metro, lines: ["Northern", "Victoria", "Piccadilly"]),
        Station(id: "gb-london-waterloo", name: "Waterloo", nameEn: "Waterloo", lat: 51.5033, lon: -0.1149, country: "GB", city: "London", type: .metro, lines: ["Bakerloo", "Northern", "Jubilee"]),
        Station(id: "gb-london-oxford", name: "Oxford Circus", nameEn: "Oxford Circus", lat: 51.5152, lon: -0.1418, country: "GB", city: "London", type: .metro, lines: ["Central", "Bakerloo", "Victoria"]),
        Station(id: "gb-london-canary", name: "Canary Wharf", nameEn: "Canary Wharf", lat: 51.5036, lon: -0.0186, country: "GB", city: "London", type: .metro, lines: ["Jubilee", "Elizabeth"]),
        Station(id: "tr-ist-taksim", name: "Taksim", nameEn: "Taksim", lat: 41.0369, lon: 28.9850, country: "TR", city: "Istanbul", type: .metro, lines: ["M2"]),
        Station(id: "tr-ist-kadikoy", name: "Kadıköy", nameEn: "Kadikoy", lat: 40.9909, lon: 29.0290, country: "TR", city: "Istanbul", type: .ferry, lines: ["IDO"]),
        Station(id: "tr-ist-eminonu", name: "Eminönü", nameEn: "Eminonu", lat: 41.0171, lon: 28.9700, country: "TR", city: "Istanbul", type: .ferry, lines: ["Sehir Hatlari"]),
        Station(id: "tr-ist-levent", name: "Levent", nameEn: "Levent", lat: 41.0818, lon: 29.0119, country: "TR", city: "Istanbul", type: .metro, lines: ["M2"]),
        Station(id: "tr-ist-yenikapi", name: "Yenikapı", nameEn: "Yenikapi", lat: 41.0054, lon: 28.9527, country: "TR", city: "Istanbul", type: .metro, lines: ["M1", "M2"])
    ]
}
