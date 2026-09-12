// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

/// Progress and opinion are intentionally independent.
enum PlayStatus: String, Codable, CaseIterable, Sendable {
    case unplayed
    case backlog
    case playing
    case paused
    case completed
}

enum GameOpinion: String, Codable, CaseIterable, Sendable {
    case unrated
    case liked
    case neutral
    case disliked
}

enum GameInterest: String, Codable, Sendable {
    case unspecified
    case interested
    case notInterested
}

struct GameRecord: Identifiable, Codable, Equatable, Sendable {
    let id: GameReleaseID
    var status: PlayStatus = .unplayed
    var opinion: GameOpinion = .unrated
    var interest: GameInterest = .unspecified
    var isOwned = false
    var isUpNext = false
    var completionDate: Date?
    var resumeNote = ""
}

struct GameShelf: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var games: [GameReleaseID]
}

/// Portable personal state. Credentials and browsing telemetry never belong here.
/// This is a draft schema; persistence and import migration are GN-030/GN-060.
struct LibrarySnapshot: Codable, Equatable, Sendable {
    var schemaVersion = 1
    var selectedPlatformIDs: [PlatformID] = []
    var favoriteGameIDs: [GameID] = []
    var records: [GameRecord] = []
    var shelves: [GameShelf] = []
}
