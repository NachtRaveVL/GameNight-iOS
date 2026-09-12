// SPDX-License-Identifier: GPL-3.0-or-later

/// Asynchronous boundaries allow actor-backed adapters without UI isolation leaks.
protocol CatalogRepository: Sendable {
    func platforms() async throws -> [GamePlatform]
    func games(matching query: CatalogQuery) async throws -> CatalogPage
}

protocol PlayerLibraryRepository: Sendable {
    func load() async throws -> LibrarySnapshot
    func save(_ snapshot: LibrarySnapshot) async throws
}

protocol ArtworkRepository: Sendable {
    func artwork(for releaseID: GameReleaseID) async throws -> [GameArtwork]
}

struct GameRecommendation: Equatable, Sendable {
    let releaseID: GameReleaseID
    let explanation: String
}

/// Recommendations are computed on-device from explicit preferences.
protocol RecommendationRepository: Sendable {
    func suggestions(for library: LibrarySnapshot) async throws -> [GameRecommendation]
}

/// Secret storage is separate from exportable personal state.
protocol CredentialStore: Sendable {
    func mobyGamesAPIKey() async throws -> String?
    func setMobyGamesAPIKey(_ key: String) async throws
    func deleteMobyGamesAPIKey() async throws
}
