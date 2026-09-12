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
            summary: String(localized: "Browse consoles, computer eras, and game collections."),
            plannedWork: [
                String(localized: "Console tiles grouped by manufacturer"),
                String(localized: "Search with visible My platforms and All platforms scope"),
                String(localized: "Genres, series, and cover grids with browsing position preserved")
            ],
            links: [
                StubLink(
                    id: "explore.eras",
                    title: String(localized: "Computer eras"),
                    systemImage: "desktopcomputer",
                    intent: .push(.computerEras)
                ),
                StubLink(
                    id: "explore.catalog",
                    title: String(localized: "Game collection stub"),
                    systemImage: "gamecontroller",
                    intent: .push(.gameCatalog(nil))
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
