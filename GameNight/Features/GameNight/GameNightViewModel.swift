// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-043): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class GameNightViewModel {
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
            id: "page.gameNight",
            title: String(localized: "Game Night mode"),
            systemImage: "person.2",
            summary: String(localized: "Pass the phone around and shortlist games together."),
            plannedWork: [
                String(localized: "Choose console and verified player count"),
                String(localized: "Keep votes and shortlists in this local session"),
                String(localized: "No friend accounts, contacts access, or social backend")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
