// SPDX-License-Identifier: GPL-3.0-or-later

/// Composition root only. Features receive individual dependencies, not this container.
struct AppDependencies: Sendable {
    let catalog: any CatalogRepository
    let library: any PlayerLibraryRepository
    let artwork: any ArtworkRepository
    let recommendations: any RecommendationRepository
    let credentials: any CredentialStore
    let computerEras: any ComputerEraRepository
    let connection: any MobyConnectionChecking

    static func scaffold() -> AppDependencies {
        AppDependencies(
            catalog: ScaffoldCatalogRepository(),
            library: ScaffoldPlayerLibraryRepository(),
            artwork: ScaffoldArtworkRepository(),
            recommendations: ScaffoldRecommendationRepository(),
            credentials: ScaffoldCredentialStore(),
            computerEras: ScaffoldComputerEraRepository(),
            connection: ScaffoldConnectionChecker()
        )
    }

    #if canImport(Security)
    /// Construction performs no disk/Keychain access or network requests.
    static func live() -> AppDependencies {
        mobyGames(credentials: KeychainCredentialStore(), library: FilePlayerLibraryRepository())
    }
    #endif

    static func mobyGames(
        credentials: any CredentialStore,
        library: any PlayerLibraryRepository = ScaffoldPlayerLibraryRepository()
    ) -> AppDependencies {
        let client = MobyAPIClient(credentials: credentials)
        return AppDependencies(
            catalog: MobyCatalogRepository(client: client),
            library: library,
            artwork: ScaffoldArtworkRepository(),
            recommendations: ScaffoldRecommendationRepository(),
            credentials: credentials,
            computerEras: ScaffoldComputerEraRepository(),
            connection: MobyConnectionChecker(client: client)
        )
    }
}
