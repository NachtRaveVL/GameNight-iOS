// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

struct LibraryModelTests {
    @Test
    func completionDoesNotImplyApprovalOrOwnership() {
        let release = GameReleaseID(gameID: GameID(rawValue: 1), platformID: PlatformID(rawValue: 2))
        var record = GameRecord(id: release)
        record.status = .completed

        #expect(record.opinion == .unrated)
        #expect(record.interest == .unspecified)
        #expect(!record.isOwned)
    }

    @Test
    func removingConsoleAccessPreservesHistory() {
        let platform = PlatformID(rawValue: 2)
        let release = GameReleaseID(gameID: GameID(rawValue: 1), platformID: platform)
        var library = LibrarySnapshot()
        library.selectedPlatformIDs = [platform]
        library.records = [GameRecord(id: release, status: .completed)]
        library.selectedPlatformIDs.removeAll()

        #expect(library.records.first?.status == .completed)
    }

    @Test
    func portableSnapshotPreservesSeparateConsoleProgressAndNotes() throws {
        let game = GameID(rawValue: 1)
        let first = GameRecord(
            id: GameReleaseID(gameID: game, platformID: PlatformID(rawValue: 2)),
            status: .completed,
            opinion: .disliked,
            resumeNote: "Finished the main story."
        )
        let second = GameRecord(
            id: GameReleaseID(gameID: game, platformID: PlatformID(rawValue: 3)),
            status: .backlog
        )
        var snapshot = LibrarySnapshot()
        snapshot.records = [first, second]
        snapshot.shelves = [GameShelf(id: UUID(), name: "Weekend", games: [second.id])]

        let bytes = try JSONEncoder().encode(snapshot)
        let restored = try JSONDecoder().decode(LibrarySnapshot.self, from: bytes)

        #expect(restored == snapshot)
        #expect(restored.records[0].id != restored.records[1].id)
        #expect(restored.records[0].status != restored.records[1].status)
    }
}
