// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-012): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class TasteSetupViewModel {
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
            id: "page.tasteSetup",
            title: String(localized: "Games you like"),
            systemImage: "heart",
            summary: String(localized: "Optional preferences for suggestions computed on this device."),
            plannedWork: [
                String(localized: "Pick favorite games and what you enjoy about them"),
                String(localized: "No implicit tracking of browsing or clicks"),
                String(localized: "Edit or remove preferences anytime")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
