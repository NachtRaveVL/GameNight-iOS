// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-040): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class DiscoverViewModel {
    let page: StubPage

    private let router: AppRouter
    private let catalog: any CatalogRepository
    private let recommendations: any RecommendationRepository
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        recommendations: any RecommendationRepository,
        library: any PlayerLibraryRepository
    ) {
        self.router = router
        self.catalog = catalog
        self.recommendations = recommendations
        self.library = library
        page = StubPage(
            id: "page.discover",
            title: String(localized: "Discover"),
            systemImage: "sparkles",
            summary: String(localized: "Find something appealing whenever you feel like playing."),
            plannedWork: [
                String(localized: "Recommendations explained through explicit preferences"),
                String(localized: "A few possibilities from your Shortlist and Backlog"),
                String(localized: "Clearly separate saved games from new discoveries; no check-ins")
            ],
            links: [
                StubLink(
                    id: "discover.game",
                    title: String(localized: "Game overview stub"),
                    systemImage: "rectangle.portrait",
                    intent: .push(.gameDetail(nil))
                ),
                StubLink(
                    id: "discover.tuning",
                    title: String(localized: "Tune suggestions"),
                    systemImage: "slider.horizontal.3",
                    intent: .push(.recommendationTuning(nil))
                ),
                StubLink(
                    id: "discover.tonight",
                    title: String(localized: "Pick a game for tonight"),
                    systemImage: "moon.stars",
                    intent: .push(.tonight)
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
