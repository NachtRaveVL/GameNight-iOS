// SPDX-License-Identifier: GPL-3.0-or-later

/// Composition root only. Features receive individual dependencies, not this container.
struct AppDependencies: Sendable {
    let catalog: any CatalogRepository
    let library: any PlayerLibraryRepository
    let artwork: any ArtworkRepository
    let recommendations: any RecommendationRepository
    let credentials: any CredentialStore
    let computerEras: any ComputerEraRepository

    static func scaffold() -> AppDependencies {
        AppDependencies(
            catalog: ScaffoldCatalogRepository(),
            library: ScaffoldPlayerLibraryRepository(),
            artwork: ScaffoldArtworkRepository(),
            recommendations: ScaffoldRecommendationRepository(),
            credentials: ScaffoldCredentialStore(),
            computerEras: ScaffoldComputerEraRepository()
        )
    }

    /// Opt-in wiring for future feature work. Construction does not send requests.
    /// Supply the real Keychain-backed CredentialStore when its implementation is ready.
    static func mobyGames(credentials: any CredentialStore) -> AppDependencies {
        let client = MobyAPIClient(credentials: credentials)
        return AppDependencies(
            catalog: MobyCatalogRepository(client: client),
            library: ScaffoldPlayerLibraryRepository(),
            artwork: ScaffoldArtworkRepository(),
            recommendations: ScaffoldRecommendationRepository(),
            credentials: credentials,
            computerEras: ScaffoldComputerEraRepository()
        )
    }
}
