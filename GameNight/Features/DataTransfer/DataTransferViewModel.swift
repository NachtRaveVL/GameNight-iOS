// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-060): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class DataTransferViewModel {
    let page: StubPage

    private let router: AppRouter
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        library: any PlayerLibraryRepository
    ) {
        self.router = router
        self.library = library
        page = StubPage(
            id: "page.dataTransfer",
            title: String(localized: "Export and import"),
            systemImage: "square.and.arrow.up",
            summary: String(localized: "Keep your collection portable across devices and future apps."),
            plannedWork: [
                String(localized: "Versioned export of consoles, shelves, notes, and preferences"),
                String(localized: "Exclude API keys and provider caches"),
                String(localized: "Validate imports and preview changes before replacing data")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
