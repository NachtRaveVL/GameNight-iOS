// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-033): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class GameNoteViewModel {
    let page: StubPage
    let releaseID: GameReleaseID?

    private let router: AppRouter
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        library: any PlayerLibraryRepository,
        releaseID: GameReleaseID? = nil
    ) {
        self.router = router
        self.library = library
        self.releaseID = releaseID
        page = StubPage(
            id: "page.gameNote",
            title: String(localized: "Your note"),
            systemImage: "bookmark",
            summary: String(localized: "Anything you want to remember? Entirely optional."),
            plannedWork: [
                String(localized: "Manual per-game, per-console note"),
                String(localized: "Show your note on the game overview"),
                String(localized: "No gameplay monitoring")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
