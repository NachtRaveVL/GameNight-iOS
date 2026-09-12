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
            summary: String(localized: "Your playing and completed games stay on this device."),
            plannedWork: [
                String(localized: "Separate progress, interest, and opinion"),
                String(localized: "Completion dates and optional personal notes"),
                String(localized: "Independent progress for each console version")
            ],
            links: [
                StubLink(
                    id: "played.note",
                    title: String(localized: "Where I left off"),
                    systemImage: "bookmark",
                    intent: .push(.resumeNote(nil))
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
