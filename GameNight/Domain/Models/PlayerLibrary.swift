// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

/// A shortlist is an unordered subset of the backlog, never a play schedule.
enum GameMembership: String, Codable, Sendable {
    case none
    case backlog
    case shortlist
}

enum GameOpinion: String, Codable, CaseIterable, Sendable {
    case unrated
    case liked
    case neutral
    case disliked
}

/// The marker itself means completed; remembering a date is optional.
struct GameCompletion: Codable, Equatable, Sendable {
    var date: Date?
}

/// Explicit personal choices only. No active-play state, sessions, rank, or last-visit timestamp.
struct GameRecord: Identifiable, Codable, Equatable, Sendable {
    let id: GameReleaseID
    private(set) var membership: GameMembership = .none
    private(set) var completion: GameCompletion?
    var opinion: GameOpinion = .unrated
    var isOwned = false
    var note = ""

    var isInBacklog: Bool { membership != .none }
    var isShortlisted: Bool { membership == .shortlist }
    var isCompleted: Bool { completion != nil }

    mutating func addToBacklog() {
        if membership == .none { membership = .backlog }
    }

    mutating func setShortlisted(_ shortlisted: Bool) {
        if shortlisted {
            membership = .shortlist
        } else if membership == .shortlist {
            membership = .backlog
        }
    }

    /// Removing a saved possibility leaves ownership, completion, opinion, and notes intact.
    mutating func removeFromBacklog() {
        membership = .none
    }

    /// Callers can retain the previous value for Undo. Re-adding later preserves this marker.
    mutating func markCompleted(on date: Date? = nil) {
        completion = GameCompletion(date: date ?? completion?.date)
        membership = .none
    }

    mutating func clearCompletion() {
        completion = nil
    }
}

struct GameShelf: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var games: Set<GameReleaseID>
}

enum LibrarySchemaError: Error, Equatable, Sendable {
    case unsupportedVersion(Int)
}

/// Draft v2 intentionally rejects the old play-status schema instead of losing its fields.
/// TODO(GN-060): Implement validated import/migration before accepting external files.
struct LibrarySnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 2
    var schemaVersion: Int { Self.currentSchemaVersion }
    var selectedPlatformIDs: [PlatformID] = []
    var selectedComputerEras: Set<ComputerEra> = []
    var favoriteGameIDs: [GameID] = []
    /// Exclusion is title-wide; it does not remove saved games or change opinions.
    var excludedGameIDs: Set<GameID> = []
    /// Storage order is not a user ranking.
    var records: [GameRecord] = []
    var shelves: [GameShelf] = []

    init() {}

    func isExcludedFromRecommendations(_ releaseID: GameReleaseID) -> Bool {
        excludedGameIDs.contains(releaseID.gameID)
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, selectedPlatformIDs, selectedComputerEras, favoriteGameIDs
        case excludedGameIDs, records, shelves
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        guard version == Self.currentSchemaVersion else { throw LibrarySchemaError.unsupportedVersion(version) }
        selectedPlatformIDs = try container.decode([PlatformID].self, forKey: .selectedPlatformIDs)
        selectedComputerEras = try container.decode(Set<ComputerEra>.self, forKey: .selectedComputerEras)
        favoriteGameIDs = try container.decode([GameID].self, forKey: .favoriteGameIDs)
        excludedGameIDs = try container.decode(Set<GameID>.self, forKey: .excludedGameIDs)
        records = try container.decode([GameRecord].self, forKey: .records)
        shelves = try container.decode([GameShelf].self, forKey: .shelves)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(selectedPlatformIDs, forKey: .selectedPlatformIDs)
        try container.encode(selectedComputerEras, forKey: .selectedComputerEras)
        try container.encode(favoriteGameIDs, forKey: .favoriteGameIDs)
        try container.encode(excludedGameIDs, forKey: .excludedGameIDs)
        try container.encode(records, forKey: .records)
        try container.encode(shelves, forKey: .shelves)
    }
}
