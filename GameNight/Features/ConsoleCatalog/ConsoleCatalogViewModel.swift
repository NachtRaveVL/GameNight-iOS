// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-021): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ConsoleCatalogViewModel {
    let page: StubPage
    let platformID: PlatformID?

    private let router: AppRouter
    private let catalog: any CatalogRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        platformID: PlatformID? = nil
    ) {
        self.router = router
        self.catalog = catalog
        self.platformID = platformID
        page = StubPage(
            id: "page.consoleCatalog",
            title: String(localized: "Console catalog"),
            systemImage: "square.grid.2x2",
            summary: String(localized: "A catalog for the selected console. No console is selected in this preview."),
            plannedWork: [
                String(localized: "Console-specific cover grid"),
                String(localized: "Search, genre filters, and explicit loading/error states"),
                String(localized: "Load subsequent results without assuming API sort order")
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
