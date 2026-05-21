//
//  CuroDevice.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 09/05/26.
//

import Foundation
import GRDB

// MARK: - CuroDevice Model

public struct CuroDevice: Identifiable, Sendable {
    public var id: Int64?
    public var name: String
    public var deviceType: CuroDeviceType
    public var createdAt: Date
    
    public init(id: Int64? = nil, name: String, deviceType: CuroDeviceType, createdAt: Date = Date()) {
        self.id        = id
        self.name      = name
        self.deviceType = deviceType
        self.createdAt = createdAt
    }
}

// MARK: - GRDB Conformances

extension CuroDevice: Codable, FetchableRecord, MutablePersistableRecord {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case deviceType = "device_type"
        case createdAt  = "created_at"
    }
    
    /// Maps Swift property names to SQLite column names.
    public enum Columns: String, ColumnExpression {
        case id, name, deviceType = "device_type", createdAt = "created_at"
    }
    
    public static var databaseTableName: String { "curo_device" }
    
    /// Called after a successful insert so the auto-generated id is written back.
    public mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

public enum CuroAlphaConnectionMode {
    case local
    case provisioning
}
