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
            summary: String(localized: "Games you intend to play, organized by console."),
            plannedWork: [
                String(localized: "Up next queue and console filters"),
                String(localized: "Start, pause, and complete with Undo"),
                String(localized: "Not now is temporary; Not interested is reversible")
            ],
            links: [
                StubLink(
                    id: "backlog.tonight",
                    title: String(localized: "Tonight shortlist"),
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
