// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-021): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class GameCatalogViewModel {
    let page: StubPage
    let collection: CatalogCollection?

    private let router: AppRouter
    private let catalog: any CatalogRepository
    private let eras: any ComputerEraRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        collection: CatalogCollection? = nil,
        eras: any ComputerEraRepository
    ) {
        self.router = router
        self.catalog = catalog
        self.collection = collection
        self.eras = eras
        page = StubPage(
            id: "page.gameCatalog",
            title: String(localized: "Game collection"),
            systemImage: "square.grid.2x2",
            summary: String(localized: "Browse a console or curated computer era. Collection loading is still unfinished."),
            plannedWork: [
                String(localized: "Cover grid for the selected platform or curated era"),
                String(localized: "Search, genre filters, and explicit loading/error states"),
                String(localized: "Preserve filters and result order; era mappings must be curated")
            ],
            links: [
                StubLink(
                    id: "catalog.game",
                    title: String(localized: "Game overview stub"),
                    systemImage: "rectangle.portrait",
                    intent: .push(.gameDetail(nil))
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
