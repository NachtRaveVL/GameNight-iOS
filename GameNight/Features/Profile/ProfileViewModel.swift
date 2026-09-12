// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-010): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ProfileViewModel {
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
            id: "page.profile",
            title: String(localized: "Profile"),
            systemImage: "person.crop.circle",
            summary: String(localized: "Your local setup. No GameNight account is required."),
            plannedWork: [
                String(localized: "Optional platform, era, and taste preferences"),
                String(localized: "User-provided API key stored separately from exports"),
                String(localized: "No adverts, analytics, or automatic diagnostic uploads")
            ],
            links: [
                StubLink(
                    id: "profile.appearance",
                    title: String(localized: "Appearance"),
                    systemImage: "paintpalette",
                    intent: .push(.appearance)
                ),
                StubLink(
                    id: "profile.consoles",
                    title: String(localized: "Your consoles"),
                    systemImage: "gamecontroller",
                    intent: .push(.consoleSelection)
                ),
                StubLink(
                    id: "profile.taste",
                    title: String(localized: "Games you like"),
                    systemImage: "heart",
                    intent: .push(.tasteSetup)
                ),
                StubLink(
                    id: "profile.key",
                    title: String(localized: "MobyGames connection"),
                    systemImage: "key",
                    intent: .push(.apiKey)
                ),
                StubLink(
                    id: "profile.artwork",
                    title: String(localized: "Artwork sources"),
                    systemImage: "photo.on.rectangle",
                    intent: .push(.artworkSources)
                ),
                StubLink(
                    id: "profile.transfer",
                    title: String(localized: "Export and import"),
                    systemImage: "square.and.arrow.up",
                    intent: .push(.dataTransfer)
                ),
                StubLink(
                    id: "profile.hidden",
                    title: String(localized: "Not interested"),
                    systemImage: "eye.slash",
                    intent: .push(.hiddenGames)
                ),
                StubLink(
                    id: "profile.onboarding",
                    title: String(localized: "Welcome walkthrough"),
                    systemImage: "hand.wave",
                    intent: .present(.onboarding)
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
