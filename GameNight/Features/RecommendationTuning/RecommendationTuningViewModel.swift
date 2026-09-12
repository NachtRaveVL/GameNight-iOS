// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-041): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class RecommendationTuningViewModel {
    let page: StubPage
    let gameID: GameID?

    private let router: AppRouter
    private let recommendations: any RecommendationRepository
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        recommendations: any RecommendationRepository,
        library: any PlayerLibraryRepository,
        gameID: GameID? = nil
    ) {
        self.router = router
        self.recommendations = recommendations
        self.library = library
        self.gameID = gameID
        page = StubPage(
            id: "page.recommendationTuning",
            title: String(localized: "More like this, but…"),
            systemImage: "slider.horizontal.3",
            summary: String(localized: "Tell GameNight which connection you want to explore."),
            plannedWork: [
                String(localized: "Explicit preferences for mechanics, setting, and atmosphere"),
                String(localized: "Different setting, another owned console, or outside the series"),
                String(localized: "Recommendations explain both similarities and differences")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
