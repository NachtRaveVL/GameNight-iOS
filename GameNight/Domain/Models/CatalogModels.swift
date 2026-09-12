// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

struct GamePlatform: Identifiable, Equatable, Sendable {
    let id: PlatformID
    let name: String
}

struct CatalogGame: Identifiable, Equatable, Sendable {
    let id: GameID
    let title: String
    let platformIDs: [PlatformID]
}

/// Explicit browsing scope; an empty console selection is not silently "all".
enum CatalogScope: Equatable, Sendable {
    case selectedPlatforms([PlatformID])
    case allPlatforms
}

struct CatalogQuery: Equatable, Sendable {
    var title = ""
    var scope: CatalogScope = .selectedPlatforms([])
    var offset = 0
}

/// An adapter normalizes provider results without coupling views to API DTOs.
struct CatalogPage: Equatable, Sendable {
    let games: [CatalogGame]
    let nextOffset: Int?
}

struct GameArtwork: Identifiable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case frontCover
        case backCover
        case media
        case screenshot
    }

    /// Provider-qualified identity, e.g. a source name plus its asset identifier.
    let id: String
    let releaseID: GameReleaseID
    let kind: Kind
    let imageURL: URL
    let sourceName: String
    let attribution: String?
    let region: String?
}
