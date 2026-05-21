//
//  CuroDeviceRepository.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 09/05/26.
//

import Foundation
import GRDB

// MARK: - CuroDeviceRepository

@MainActor
public final class CuroDeviceRepository: ObservableObject {
    public static let shared = CuroDeviceRepository()
    
    @Published public var devices: [CuroDevice] = []

    private let db: AppDatabase

    public init(database: AppDatabase = .shared) {
        self.db = database
        refresh()
    }

    // MARK: - Create

    /// Inserts a new device and returns the persisted record (with its new `id`).
    @discardableResult
    public func add(name: String, type: CuroDeviceType) throws -> CuroDevice {
        var device = CuroDevice(name: name, deviceType: type)
        try db.write { database in
            try device.insert(database)
        }
        refresh()
        return device
    }

    /// Inserts a pre-built `CuroDevice` (useful when the caller already has the struct).
    @discardableResult
    func add(_ device: CuroDevice) throws -> CuroDevice {
        var mutable = device
        try db.write { database in
            try mutable.insert(database)
        }
        return mutable
    }

    // MARK: - Read

    /// Returns every device, ordered by name.
    func fetchAll() throws -> [CuroDevice] {
        try db.read { database in
            try CuroDevice
                .order(CuroDevice.Columns.name)
                .fetchAll(database)
        }
    }

    /// Returns devices filtered by type.
    func fetch(type: CuroDeviceType) throws -> [CuroDevice] {
        try db.read { database in
            try CuroDevice
                .filter(CuroDevice.Columns.deviceType == type.rawValue)
                .order(CuroDevice.Columns.name)
                .fetchAll(database)
        }
    }

    /// Returns a single device by its primary key, or `nil` if not found.
    func fetch(id: Int64) throws -> CuroDevice? {
        try db.read { database in
            try CuroDevice.fetchOne(database, key: id)
        }
    }

    /// Returns devices whose name contains the search string (case-insensitive).
    func search(name: String) throws -> [CuroDevice] {
        let pattern = "%\(name)%"
        return try db.read { database in
            try CuroDevice
                .filter(sql: "name LIKE ?", arguments: [pattern])
                .order(CuroDevice.Columns.name)
                .fetchAll(database)
        }
    }

    // MARK: - Update

    /// Updates an existing device. Throws if the device has no `id`.
    func update(_ device: CuroDevice) throws {
        guard device.id != nil else {
            throw CuroDeviceError.missingID
        }
        try db.write { database in
            try device.update(database)
        }
        refresh()
    }

    /// Convenience: rename a device by id.
    func rename(id: Int64, to newName: String) throws {
        guard var device = try fetch(id: id) else {
            throw CuroDeviceError.notFound(id: id)
        }
        device.name = newName
        try update(device)
    }

    // MARK: - Delete

    /// Removes a device by its `id`.
    @discardableResult
    public func remove(id: Int64) throws -> Bool {
        return try db.write { database in
            let isDeleted = try CuroDevice.deleteOne(database, key: id)
            refresh()
            return isDeleted
        }
    }

    /// Removes a device struct (must have a non-nil `id`).
    func remove(_ device: CuroDevice) throws {
        guard let id = device.id else {
            throw CuroDeviceError.missingID
        }
        try remove(id: id)
        refresh()
    }

    /// Removes all devices of a given type.
    func removeAll(type: CuroDeviceType) throws {
        _ = try db.write { database in
            try CuroDevice
                .filter(CuroDevice.Columns.deviceType == type.rawValue)
                .deleteAll(database)
        }
    }

    /// Removes every device in the table.
    func removeAll() throws {
        _ = try db.write { database in
            try CuroDevice.deleteAll(database)
        }
    }

    // MARK: - Async variants (Swift Concurrency)

    func addAsync(name: String, type: CuroDeviceType) async throws -> CuroDevice {
        var device = CuroDevice(name: name, deviceType: type)
        try await db.writeAsync { database in
            try device.insert(database)
        }
        return device
    }

    func fetchAllAsync() async throws -> [CuroDevice] {
        try await db.readAsync { database in
            try CuroDevice.order(CuroDevice.Columns.name).fetchAll(database)
        }
    }

    public func removeAsync(id: Int64) async throws {
        _ = try await db.writeAsync { database in
            try CuroDevice.deleteOne(database, key: id)
        }
        refresh()
    }
    
    func refresh() {
        devices = (try? fetchAll()) ?? []
    }
}

// MARK: - Errors

enum CuroDeviceError: LocalizedError {
    case missingID
    case notFound(id: Int64)

    var errorDescription: String? {
        switch self {
        case .missingID:
            return "The CuroDevice has no id. Save it before updating or deleting."
        case .notFound(let id):
            return "No CuroDevice found with id \(id)."
        }
    }
}
