// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

struct LibraryModelTests {
    private let release = GameReleaseID(gameID: GameID(rawValue: 1), platformID: PlatformID(rawValue: 2))

    @Test
    func shortlistIsAnUnorderedBacklogSubset() {
        var record = GameRecord(id: release)
        record.setShortlisted(true)
        #expect(record.isInBacklog && record.isShortlisted)
        record.addToBacklog()
        #expect(record.isShortlisted)
        record.setShortlisted(false)
        #expect(record.isInBacklog && !record.isShortlisted)
        record.removeFromBacklog()
        #expect(!record.isInBacklog && !record.isShortlisted)
        record.setShortlisted(false)
        #expect(!record.isInBacklog)
    }

    @Test
    func completionClearsSavedMembershipWithoutImplyingApprovalOrOwnership() {
        var record = GameRecord(id: release)
        record.setShortlisted(true)
        let before = record
        record.markCompleted()
        #expect(record.isCompleted)
        #expect(record.completion?.date == nil)
        #expect(!record.isInBacklog && !record.isShortlisted)
        #expect(record.opinion == .unrated && !record.isOwned)
        record = before // Undo restores the actual prior choices.
        #expect(!record.isCompleted && record.isShortlisted)
    }

    @Test
    func completedGamesCanBeSavedAgainWithoutLosingTheirHistory() {
        var record = GameRecord(id: release)
        let date = Date(timeIntervalSince1970: 1234)
        record.markCompleted(on: date)
        record.setShortlisted(true)
        #expect(record.isCompleted && record.isShortlisted)
        #expect(record.completion?.date == date)
        record.clearCompletion()
        #expect(!record.isCompleted && record.isShortlisted)
    }

    @Test
    func removingFromBacklogPreservesOtherPersonalChoices() {
        var record = GameRecord(id: release)
        record.markCompleted()
        record.setShortlisted(true)
        record.note = "Try the other ending someday."
        record.opinion = .liked
        record.isOwned = true
        record.removeFromBacklog()
        #expect(record.isCompleted && record.isOwned && record.opinion == .liked)
        #expect(record.note == "Try the other ending someday.")
    }

    @Test
    func exclusionsApplyAcrossVersionsWithoutRemovingSavedGames() {
        let other = GameReleaseID(gameID: release.gameID, platformID: PlatformID(rawValue: 3))
        var snapshot = LibrarySnapshot()
        var record = GameRecord(id: release)
        record.addToBacklog()
        snapshot.records = [record]
        snapshot.excludedGameIDs.insert(release.gameID)
        #expect(snapshot.isExcludedFromRecommendations(other))
        #expect(snapshot.records == [record])
        snapshot.excludedGameIDs.remove(release.gameID)
        #expect(!snapshot.isExcludedFromRecommendations(other))
    }

    @Test
    func deselectingPlatformsAndErasPreservesPersonalRecords() {
        var snapshot = LibrarySnapshot()
        var record = GameRecord(id: release)
        record.markCompleted()
        snapshot.records = [record]
        snapshot.selectedPlatformIDs = [release.platformID]
        snapshot.selectedComputerEras = [.dos, .windows9x]
        snapshot.selectedPlatformIDs.removeAll()
        snapshot.selectedComputerEras.removeAll()
        #expect(snapshot.records == [record])
    }

    @Test
    func portableSnapshotPreservesIndependentCompletionMembershipAndNotes() throws {
        var first = GameRecord(id: release)
        first.markCompleted()
        first.addToBacklog()
        first.note = "Another possibility."
        var second = GameRecord(id: GameReleaseID(gameID: release.gameID, platformID: PlatformID(rawValue: 3)))
        second.setShortlisted(true)
        var snapshot = LibrarySnapshot()
        snapshot.records = [first, second]
        snapshot.selectedComputerEras = [.windows9x, .macOSPowerPC]
        snapshot.excludedGameIDs = [GameID(rawValue: 4)]
        snapshot.shelves = [GameShelf(id: UUID(), name: "Possibilities", games: [first.id, second.id])]
        let data = try JSONEncoder().encode(snapshot)
        let restored = try JSONDecoder().decode(LibrarySnapshot.self, from: data)
        #expect(restored == snapshot)
        #expect(restored.records[0].isCompleted && restored.records[0].isInBacklog)
        #expect(!restored.records[1].isCompleted && restored.records[1].isShortlisted)
    }

    @Test
    func obsoleteAndFutureSchemasAreRejectedInsteadOfSilentlyLosingState() {
        for version in [1, 3] {
            let data = Data("{\"schemaVersion\":\(version)}".utf8)
            #expect(throws: LibrarySchemaError.unsupportedVersion(version)) {
                _ = try JSONDecoder().decode(LibrarySnapshot.self, from: data)
            }
        }
    }
}
