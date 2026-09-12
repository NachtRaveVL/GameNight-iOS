// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-032): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ShelvesViewModel {
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
            id: "page.shelves",
            title: String(localized: "Personal shelves"),
            systemImage: "books.vertical",
            summary: String(localized: "Keep your own small, named game collections."),
            plannedWork: [
                String(localized: "Create, rename, and remove shelves"),
                String(localized: "A game can belong to several shelves"),
                String(localized: "Shelf membership does not change completion or interest")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
