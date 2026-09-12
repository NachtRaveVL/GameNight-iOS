// SPDX-License-Identifier: GPL-3.0-or-later

/// Asynchronous boundaries allow actor-backed adapters without UI isolation leaks.
protocol CatalogRepository: Sendable {
    func platforms() async throws -> [GamePlatform]
    func games(matching query: CatalogQuery) async throws -> CatalogPage
}

/// Curated metadata owned by GameNight. Era membership is never inferred by the API client.
protocol ComputerEraRepository: Sendable {
    func assignments(in era: ComputerEra) async throws -> [ComputerEraAssignment]
}

protocol PlayerLibraryRepository: Sendable {
    func load() async throws -> LibrarySnapshot
    func save(_ snapshot: LibrarySnapshot) async throws
    @discardableResult
    func update(_ mutation: @Sendable (inout LibrarySnapshot) throws -> Void) async throws -> LibrarySnapshot
}

protocol ArtworkRepository: Sendable {
    func artwork(for releaseID: GameReleaseID) async throws -> [GameArtwork]
}

struct GameRecommendation: Equatable, Sendable {
    let releaseID: GameReleaseID
    let explanation: String
}

/// On-device suggestions use explicit preferences and honor title-wide exclusions.
/// Backlog/Shortlist are possibilities, never ranked tasks. No session/visit history is accepted.
protocol RecommendationRepository: Sendable {
    func suggestions(for library: LibrarySnapshot) async throws -> [GameRecommendation]
}

/// Secret storage is separate from exportable personal state.
protocol CredentialStore: Sendable {
    func mobyGamesAPIKey() async throws -> String?
    func setMobyGamesAPIKey(_ key: String) async throws
    func deleteMobyGamesAPIKey() async throws
}

/// Only an explicit user action should trigger this network operation.
protocol MobyConnectionChecking: Sendable {
    func checkConnection() async throws
}
