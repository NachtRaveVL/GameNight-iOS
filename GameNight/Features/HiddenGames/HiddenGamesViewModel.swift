// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-034): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class HiddenGamesViewModel {
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
            id: "page.hiddenGames",
            title: String(localized: "Not interested"),
            systemImage: "eye.slash",
            summary: String(localized: "Review games you have excluded from suggestions."),
            plannedWork: [
                String(localized: "Restore a title without losing progress or notes"),
                String(localized: "Keep explicit disinterest separate from opinion"),
                String(localized: "One excluded title does not blacklist a genre")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
