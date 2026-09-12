// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-051): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ArtworkSourcesViewModel {
    let page: StubPage

    private let router: AppRouter
    private let artwork: any ArtworkRepository

    init(
        router: AppRouter,
        artwork: any ArtworkRepository
    ) {
        self.router = router
        self.artwork = artwork
        page = StubPage(
            id: "page.artworkSources",
            title: String(localized: "Artwork sources"),
            systemImage: "photo.stack",
            summary: String(localized: "Choose compatible artwork packs and personal cover overrides."),
            plannedWork: [
                String(localized: "MobyGames plus sources with suitable reuse permissions"),
                String(localized: "Match game, console, region, and edition"),
                String(localized: "Track attribution and support user-imported artwork")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
