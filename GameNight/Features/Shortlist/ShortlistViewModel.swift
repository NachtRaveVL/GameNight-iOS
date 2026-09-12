// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-030): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ShortlistViewModel {
    let page: StubPage
    private let router: AppRouter
    private let library: any PlayerLibraryRepository

    init(router: AppRouter, library: any PlayerLibraryRepository) {
        self.router = router
        self.library = library
        page = StubPage(
            id: "page.shortlist",
            title: String(localized: "Shortlist"),
            systemImage: "star",
            summary: String(localized: "A handful of possibilities that catch your interest."),
            plannedWork: [
                String(localized: "An unordered subset of your Backlog; no ranks or schedules"),
                String(localized: "Removing a game from Shortlist keeps it in Backlog"),
                String(localized: "No check-ins, reminders, or expectations to finish")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
