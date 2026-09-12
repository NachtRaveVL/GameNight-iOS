// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

struct LocalStorageTests {
    private func location() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("GameNight-tests-\(UUID().uuidString)")
    }

    @Test
    func firstLoadIsEmptyAndSavedChoicesSurviveANewRepository() async throws {
        let directory = location()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = FilePlayerLibraryRepository(directory: directory)
        #expect(try await repository.load() == LibrarySnapshot())
        #expect(!FileManager.default.fileExists(atPath: directory.appendingPathComponent("library.json").path))
        let release = GameReleaseID(gameID: GameID(rawValue: 1), platformID: PlatformID(rawValue: 2))
        let snapshot = try await repository.update { library in
            library.selectedPlatformIDs = [release.platformID]
            library.selectedComputerEras = [.dos, .windows9x]
            library.favoriteGameIDs = [release.gameID]
            library.excludedGameIDs = [GameID(rawValue: 3)]
            var record = GameRecord(id: release)
            record.markCompleted()
            record.setShortlisted(true)
            record.note = "Try another ending."
            record.isOwned = true
            record.opinion = .liked
            library.records = [record]
            library.shelves = [GameShelf(id: UUID(), name: "Possibilities", games: [release])]
        }
        let reopened = FilePlayerLibraryRepository(directory: directory)
        #expect(try await reopened.load() == snapshot)
        let filenames = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        #expect(filenames == ["library.json"])
    }

    @Test
    func concurrentEditsDoNotLoseOtherFeaturesChanges() async throws {
        let directory = location()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = FilePlayerLibraryRepository(directory: directory)
        try await withThrowingTaskGroup(of: Void.self) { group in
            for value in 1...30 {
                group.addTask {
                    try await repository.update { library in
                        library.excludedGameIDs.insert(GameID(rawValue: value))
                    }
                }
            }
            try await group.waitForAll()
        }
        #expect(try await repository.load().excludedGameIDs.count == 30)
    }

    @Test
    func corruptUnsupportedAndOversizedFilesArePreserved() async throws {
        for bytes in [Data("broken JSON".utf8), Data(#"{"schemaVersion":1}"#.utf8), Data(repeating: 32, count: 8 * 1024 * 1024 + 1)] {
            let directory = location()
            defer { try? FileManager.default.removeItem(at: directory) }
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let file = directory.appendingPathComponent("library.json")
            try bytes.write(to: file)
            let repository = FilePlayerLibraryRepository(directory: directory)
            await #expect(throws: LibraryStorageError.self) { _ = try await repository.load() }
            await #expect(throws: LibraryStorageError.self) { try await repository.save(LibrarySnapshot()) }
            #expect(try Data(contentsOf: file) == bytes)
        }
    }

    @Test
    func invalidAndThrowingUpdatesLeaveTheCommittedSnapshotUntouched() async throws {
        let directory = location()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = FilePlayerLibraryRepository(directory: directory)
        let before = try await repository.update { $0.selectedComputerEras = [.windows9x] }
        await #expect(throws: LibraryStorageError.invalidData) {
            try await repository.update { $0.selectedPlatformIDs = [PlatformID(rawValue: -1)] }
        }
        await #expect(throws: LibraryStorageError.invalidData) {
            try await repository.update {
                $0.favoriteGameIDs = [GameID(rawValue: 1), GameID(rawValue: 1)]
            }
        }
        await #expect(throws: LibraryStorageError.unavailable) {
            try await repository.update {
                $0.selectedComputerEras = []
                throw LibraryStorageError.unavailable
            }
        }
        #expect(try await repository.load() == before)
    }

    @Test
    func cancellationBeforeCommitDoesNotWrite() async throws {
        let directory = location()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = FilePlayerLibraryRepository(directory: directory)
        let before = try await repository.update { $0.selectedComputerEras = [.dos] }
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            try await repository.update { $0.selectedComputerEras = [.windows9x] }
        }
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(try await repository.load() == before)
    }

    #if os(iOS)
    @Test
    func persistedFileUsesCompleteProtectionAndBackupExclusion() async throws {
        let directory = location()
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = FilePlayerLibraryRepository(directory: directory)
        try await repository.update { $0.selectedComputerEras = [.dos] }
        // Exercise replacement as well as first creation: metadata belongs to the new inode.
        try await repository.update { $0.selectedComputerEras.insert(.windows9x) }
        let file = directory.appendingPathComponent("library.json")
        let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
        #expect(attributes[.protectionKey] as? FileProtectionType == .complete)
        #expect(try file.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
    }
    #endif
}
