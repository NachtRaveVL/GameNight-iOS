// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-010): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class OnboardingViewModel {
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
            id: "page.onboarding",
            title: String(localized: "Welcome to GameNight"),
            systemImage: "gamecontroller",
            summary: String(localized: "Choose what you play on, then optionally choose a few favorites."),
            plannedWork: [
                String(localized: "No GameNight registration"),
                String(localized: "Skippable console and taste setup"),
                String(localized: "This welcome stub appears each launch until local settings are implemented")
            ],
            links: [
                StubLink(
                    id: "onboarding.consoles",
                    title: String(localized: "Console setup stub"),
                    systemImage: "gamecontroller",
                    intent: .push(.consoleSelection)
                ),
                StubLink(
                    id: "onboarding.taste",
                    title: String(localized: "Taste setup stub"),
                    systemImage: "heart",
                    intent: .push(.tasteSetup)
                ),
                StubLink(
                    id: "onboarding.continue",
                    title: String(localized: "Continue to app shell"),
                    systemImage: "arrow.right",
                    intent: .dismissSheet
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
