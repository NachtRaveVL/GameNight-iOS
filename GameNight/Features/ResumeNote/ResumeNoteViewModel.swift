// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-033): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ResumeNoteViewModel {
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
            id: "page.resumeNote",
            title: String(localized: "Where I left off"),
            systemImage: "bookmark",
            summary: String(localized: "A private note to help you return to a game."),
            plannedWork: [
                String(localized: "Manual per-game, per-console note"),
                String(localized: "Show the note when resuming"),
                String(localized: "No gameplay monitoring")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
