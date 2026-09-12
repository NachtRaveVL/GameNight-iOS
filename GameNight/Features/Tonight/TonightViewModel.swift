// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-042): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class TonightViewModel {
    let page: StubPage

    private let router: AppRouter
    private let library: any PlayerLibraryRepository
    private let recommendations: any RecommendationRepository

    init(
        router: AppRouter,
        library: any PlayerLibraryRepository,
        recommendations: any RecommendationRepository
    ) {
        self.router = router
        self.library = library
        self.recommendations = recommendations
        page = StubPage(
            id: "page.tonight",
            title: String(localized: "Pick a game for tonight"),
            systemImage: "moon.stars",
            summary: String(localized: "A few suggestions from your Shortlist and Backlog."),
            plannedWork: [
                String(localized: "A small selection with clear reasons, without creating an assignment"),
                String(localized: "Replace one candidate or request another set"),
                String(localized: "Replacing a suggestion changes only this visit, never your preferences")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
