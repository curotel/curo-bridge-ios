//
//  AppDatabase.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 09/05/26.
//

import Foundation
import GRDB

// MARK: - AppDatabase

@MainActor
public final class AppDatabase {

    // MARK: Shared instance

    public static let shared: AppDatabase = {
        let dbURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("curo.sqlite")
        return try! AppDatabase(path: dbURL.path)
    }()

    // MARK: In-memory instance (for tests / previews)

    static func makeInMemory() throws -> AppDatabase {
        try AppDatabase(path: ":memory:")
    }

    // MARK: Internal storage

    private let dbPool: DatabasePool          // multi-reader / single-writer

    // MARK: Init

    public init(path: String) throws {
        var config = Configuration()
        config.prepareDatabase { db in
            // Enable WAL mode for better concurrency.
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            // Enforce foreign-key constraints.
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }

        dbPool = try DatabasePool(path: path, configuration: config)
        try migrate()
    }

    // MARK: - Migrations

    private func migrate() throws {
        var migrator = DatabaseMigrator()

        // ── v1 – initial schema ────────────────────────────────────────────────
        migrator.registerMigration("v1_create_curo_device") { db in
            try db.create(table: CuroDevice.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name",        .text).notNull()
                t.column("device_type", .text).notNull()   // "alpha" | "stethoscope"
                t.column("created_at",  .datetime).notNull()
            }
        }

        // ── v2 – example future migration (add an index) ───────────────────────
        migrator.registerMigration("v2_index_device_type") { db in
            try db.create(
                index: "idx_curo_device_type",
                on:    CuroDevice.databaseTableName,
                columns: ["device_type"]
            )
        }

        // Add future migrations here; GRDB applies only the ones not yet run.
        // migrator.registerMigration("v3_...") { ... }

        try migrator.migrate(dbPool)
    }

    // MARK: - Read / Write accessors (exposed to repositories)

    /// Synchronous write (blocking the calling thread).
    func write<T>(_ updates: (Database) throws -> T) throws -> T {
        try dbPool.write(updates)
    }

    /// Synchronous read.
    func read<T>(_ block: (Database) throws -> T) throws -> T {
        try dbPool.read(block)
    }

    /// Async write using Swift Concurrency.
    func writeAsync<T>(_ updates: @escaping (Database) throws -> T) async throws -> T {
        try dbPool.write(updates)
    }

    /// Async read.
    func readAsync<T>(_ block: @escaping (Database) throws -> T) async throws -> T {
        try dbPool.read(block)
    }
}
