import Foundation
import SQLite3

protocol DashboardDataSource: Sendable {
    func loadSnapshot() throws -> DashboardSnapshot
}

struct SeedDashboardDataSource: DashboardDataSource {
    func loadSnapshot() throws -> DashboardSnapshot {
        let resourceURL = Bundle.main.url(forResource: "seed", withExtension: "json")
            ?? Bundle.module.url(forResource: "seed", withExtension: "json")

        guard let resourceURL else {
            throw DashboardDataError.missingSeed
        }

        let data = try Data(contentsOf: resourceURL)
        return try JSONDecoder().decode(DashboardSnapshot.self, from: data)
    }
}

struct SQLiteDashboardDataSource: DashboardDataSource {
    let databaseURL: URL

    init(databaseURL: URL = Self.defaultDatabaseURL) {
        self.databaseURL = databaseURL
    }

    static var defaultDatabaseURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("com.pedroavj.bbva", isDirectory: true)
            .appendingPathComponent("PrivateStore", isDirectory: true)
            .appendingPathComponent("dashboard.sqlite3", isDirectory: false)
    }

    func loadSnapshot() throws -> DashboardSnapshot {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            throw DashboardDataError.missingDatabase(databaseURL.path)
        }

        var database: OpaquePointer?
        let openResult = sqlite3_open_v2(
            databaseURL.path,
            &database,
            SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX,
            nil
        )
        guard openResult == SQLITE_OK, let database else {
            if let database { sqlite3_close(database) }
            throw DashboardDataError.databaseFailure("Unable to open the private dashboard database.")
        }
        defer { sqlite3_close(database) }

        let sql = "SELECT payload FROM dashboard_snapshot WHERE id = 1"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            throw DashboardDataError.databaseFailure(Self.message(from: database))
        }
        defer { sqlite3_finalize(statement) }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw DashboardDataError.missingSnapshot
        }
        guard let bytes = sqlite3_column_blob(statement, 0) else {
            throw DashboardDataError.missingSnapshot
        }

        let length = Int(sqlite3_column_bytes(statement, 0))
        let data = Data(bytes: bytes, count: length)
        do {
            return try JSONDecoder().decode(DashboardSnapshot.self, from: data)
        } catch {
            throw DashboardDataError.invalidSnapshot(error.localizedDescription)
        }
    }

    private static func message(from database: OpaquePointer) -> String {
        String(cString: sqlite3_errmsg(database))
    }
}

enum DashboardDataError: LocalizedError {
    case missingSeed
    case missingDatabase(String)
    case missingSnapshot
    case databaseFailure(String)
    case invalidSnapshot(String)

    var errorDescription: String? {
        switch self {
        case .missingSeed:
            return "The bundled sample dashboard could not be found."
        case let .missingDatabase(path):
            return "The private dashboard database is missing at \(path)."
        case .missingSnapshot:
            return "The private dashboard database has no active snapshot."
        case let .databaseFailure(reason):
            return "The private dashboard database could not be read: \(reason)"
        case let .invalidSnapshot(reason):
            return "The private dashboard snapshot is invalid: \(reason)"
        }
    }
}
