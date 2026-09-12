// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// One actor per library file in the composition root. No work happens in init.
/// Read/modify/write has no suspension points, so concurrent feature edits cannot interleave.
actor FilePlayerLibraryRepository: PlayerLibraryRepository {
    private let directory: URL?
    private let maximumBytes = 8 * 1024 * 1024

    init(directory: URL? = nil) {
        self.directory = directory
    }

    func load() throws -> LibrarySnapshot {
        try Task.checkCancellation()
        return try readSnapshot()
    }

    /// Whole-snapshot replacement is reserved for deliberate restore/import operations.
    /// Normal feature edits must use update to avoid saving stale copies over each other.
    func save(_ snapshot: LibrarySnapshot) throws {
        try Task.checkCancellation()
        _ = try readSnapshot() // Never overwrite corrupt or unsupported existing data.
        try writeSnapshot(snapshot)
    }

    @discardableResult
    func update(_ mutation: @Sendable (inout LibrarySnapshot) throws -> Void) throws -> LibrarySnapshot {
        try Task.checkCancellation()
        var snapshot = try readSnapshot()
        try mutation(&snapshot)
        try writeSnapshot(snapshot)
        return snapshot
    }

    private func storageDirectory() throws -> URL {
        if let directory { return directory }
        guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw LibraryStorageError.unavailable
        }
        return support.appendingPathComponent("GameNight", isDirectory: true)
    }

    private func readSnapshot() throws -> LibrarySnapshot {
        let url = try storageDirectory().appendingPathComponent("library.json")
        let data: Data
        do {
            let handle = try FileHandle(forReadingFrom: url)
            // Closing a read handle is cleanup only; never hide a read/decoding failure.
            defer { try? handle.close() }
            var contents = Data()
            while contents.count <= maximumBytes {
                try Task.checkCancellation()
                guard let chunk = try handle.read(upToCount: min(65536, maximumBytes + 1 - contents.count)),
                      !chunk.isEmpty else { break }
                contents.append(chunk)
            }
            data = contents
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            return LibrarySnapshot()
        } catch {
            throw LibraryStorageError.unavailable
        }
        guard data.count <= maximumBytes else { throw LibraryStorageError.tooLarge }
        do {
            let snapshot = try JSONDecoder().decode(LibrarySnapshot.self, from: data)
            try snapshot.validateForStorage()
            try Task.checkCancellation()
            return snapshot
        } catch is CancellationError {
            throw CancellationError()
        } catch LibrarySchemaError.unsupportedVersion(let version) {
            throw LibraryStorageError.unsupportedVersion(version)
        } catch {
            throw LibraryStorageError.invalidData
        }
    }

    private func writeSnapshot(_ snapshot: LibrarySnapshot) throws {
        try snapshot.validateForStorage()
        let data: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            data = try encoder.encode(snapshot)
        } catch {
            throw LibraryStorageError.invalidData
        }
        guard data.count <= maximumBytes else { throw LibraryStorageError.tooLarge }
        let directory = try storageDirectory()
        let destination = directory.appendingPathComponent("library.json")
        let temporary = directory.appendingPathComponent("library-\(UUID().uuidString).tmp")
        // Failure cleanup only. rename removes this path after a successful commit.
        defer { try? FileManager.default.removeItem(at: temporary) }
        do {
            try Task.checkCancellation()
            #if os(iOS)
            try FileManager.default.createDirectory(
                at: directory, withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.complete]
            )
            try excludeFromBackup(directory)
            try data.write(to: temporary, options: [.withoutOverwriting, .completeFileProtection])
            try excludeFromBackup(temporary)
            #else
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: temporary, options: .withoutOverwriting)
            #endif
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: temporary.path)
            let handle = try FileHandle(forWritingTo: temporary)
            do {
                try handle.synchronize()
                try handle.close()
            } catch {
                try? handle.close()
                throw error
            }
            try Task.checkCancellation()
            // Same-directory rename atomically replaces the destination. Protection and
            // backup metadata are already on the staged file before it becomes visible.
            guard rename(temporary.path, destination.path) == 0 else { throw LibraryStorageError.unavailable }
            // A committed write returns success even if cancellation arrives afterward.
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw LibraryStorageError.unavailable
        }
    }

    #if os(iOS)
    // This is guidance to the OS, not a guarantee about every OS-managed backup.
    private func excludeFromBackup(_ url: URL) throws {
        var url = url
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }
    #endif
}
