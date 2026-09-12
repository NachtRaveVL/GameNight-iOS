// SPDX-License-Identifier: GPL-3.0-or-later

enum ScaffoldCapability: String, Sendable {
    case catalog
    case localStorage
    case artwork
    case recommendations
    case credentials
}

/// Unimplemented operations fail explicitly instead of pretending to save or load.
enum ScaffoldError: Error, Equatable, Sendable {
    case notImplemented(ScaffoldCapability)
}

struct ScaffoldCatalogRepository: CatalogRepository {
    func platforms() async throws -> [GamePlatform] {
        throw ScaffoldError.notImplemented(.catalog)
    }

    func games(matching query: CatalogQuery) async throws -> CatalogPage {
        throw ScaffoldError.notImplemented(.catalog)
    }
}

struct ScaffoldPlayerLibraryRepository: PlayerLibraryRepository {
    func load() async throws -> LibrarySnapshot {
        throw ScaffoldError.notImplemented(.localStorage)
    }

    func save(_ snapshot: LibrarySnapshot) async throws {
        throw ScaffoldError.notImplemented(.localStorage)
    }
}

struct ScaffoldArtworkRepository: ArtworkRepository {
    func artwork(for releaseID: GameReleaseID) async throws -> [GameArtwork] {
        throw ScaffoldError.notImplemented(.artwork)
    }
}

struct ScaffoldRecommendationRepository: RecommendationRepository {
    func suggestions(for library: LibrarySnapshot) async throws -> [GameRecommendation] {
        throw ScaffoldError.notImplemented(.recommendations)
    }
}

struct ScaffoldCredentialStore: CredentialStore {
    func mobyGamesAPIKey() async throws -> String? {
        throw ScaffoldError.notImplemented(.credentials)
    }

    func setMobyGamesAPIKey(_ key: String) async throws {
        throw ScaffoldError.notImplemented(.credentials)
    }

    func deleteMobyGamesAPIKey() async throws {
        throw ScaffoldError.notImplemented(.credentials)
    }
}
