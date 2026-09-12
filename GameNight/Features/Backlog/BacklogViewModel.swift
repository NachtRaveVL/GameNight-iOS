// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-030): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class BacklogViewModel {
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
            id: "page.backlog",
            title: String(localized: "Backlog"),
            systemImage: "list.bullet",
            summary: String(localized: "Possibilities to return to whenever you feel like it."),
            plannedWork: [
                String(localized: "An unordered Shortlist within your Backlog"),
                String(localized: "Optional completion with Undo; save completed games again"),
                String(localized: "Not now is temporary; Not interested is reversible")
            ],
            links: [
                StubLink(
                    id: "backlog.shortlist",
                    title: String(localized: "Shortlist"),
                    systemImage: "star",
                    intent: .push(.shortlist)
                ),
                StubLink(
                    id: "backlog.tonight",
                    title: String(localized: "Pick a game for tonight"),
                    systemImage: "moon.stars",
                    intent: .push(.tonight)
                ),
                StubLink(
                    id: "backlog.shelves",
                    title: String(localized: "Personal shelves"),
                    systemImage: "books.vertical",
                    intent: .push(.shelves)
                ),
                StubLink(
                    id: "backlog.gameNight",
                    title: String(localized: "Game Night mode"),
                    systemImage: "person.2",
                    intent: .push(.gameNight)
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
