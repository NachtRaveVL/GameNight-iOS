// SPDX-License-Identifier: GPL-3.0-or-later

/// Composition root only. Features receive individual dependencies, not this container.
struct AppDependencies: Sendable {
    let catalog: any CatalogRepository
    let library: any PlayerLibraryRepository
    let artwork: any ArtworkRepository
    let recommendations: any RecommendationRepository
    let credentials: any CredentialStore

    static func scaffold() -> AppDependencies {
        AppDependencies(
            catalog: ScaffoldCatalogRepository(),
            library: ScaffoldPlayerLibraryRepository(),
            artwork: ScaffoldArtworkRepository(),
            recommendations: ScaffoldRecommendationRepository(),
            credentials: ScaffoldCredentialStore()
        )
    }
}
