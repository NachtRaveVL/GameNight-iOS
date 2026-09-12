// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-011): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ConsoleSelectionViewModel {
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
            id: "page.consoleSelection",
            title: String(localized: "Your consoles"),
            systemImage: "gamecontroller",
            summary: String(localized: "Optionally choose consoles, handhelds, and computer eras you enjoy."),
            plannedWork: [
                String(localized: "Console groups and computer eras with separate platform identities"),
                String(localized: "Edit selections without deleting game history"),
                String(localized: "Keep console access separate from game ownership")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
