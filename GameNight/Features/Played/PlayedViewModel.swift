// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-031): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class PlayedViewModel {
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
            id: "page.played",
            title: String(localized: "Played"),
            systemImage: "checkmark.circle",
            summary: String(localized: "Games you have chosen to mark completed, with optional opinions."),
            plannedWork: [
                String(localized: "Completion never implies liking or owning a game"),
                String(localized: "Completion dates and optional personal notes"),
                String(localized: "Separate completion for each console version; no completion targets")
            ],
            links: [
                StubLink(
                    id: "played.note",
                    title: String(localized: "Your note"),
                    systemImage: "bookmark",
                    intent: .push(.gameNote(nil))
                ),
                StubLink(
                    id: "played.game",
                    title: String(localized: "Game overview stub"),
                    systemImage: "rectangle.portrait",
                    intent: .push(.gameDetail(nil))
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
