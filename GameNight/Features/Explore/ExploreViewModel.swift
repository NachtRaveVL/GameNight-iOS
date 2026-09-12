// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-020): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ExploreViewModel {
    let page: StubPage

    private let router: AppRouter
    private let catalog: any CatalogRepository
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        library: any PlayerLibraryRepository
    ) {
        self.router = router
        self.catalog = catalog
        self.library = library
        page = StubPage(
            id: "page.explore",
            title: String(localized: "Explore"),
            systemImage: "magnifyingglass",
            summary: String(localized: "Browse game catalogs by console."),
            plannedWork: [
                String(localized: "Console tiles grouped by manufacturer"),
                String(localized: "Search with a clearly visible console scope"),
                String(localized: "Genre filters and a browsable cover grid")
            ],
            links: [
                StubLink(
                    id: "explore.catalog",
                    title: String(localized: "Console catalog stub"),
                    systemImage: "gamecontroller",
                    intent: .push(.consoleCatalog(nil))
                ),
                StubLink(
                    id: "explore.consoles",
                    title: String(localized: "Choose consoles"),
                    systemImage: "checklist",
                    intent: .push(.consoleSelection)
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
