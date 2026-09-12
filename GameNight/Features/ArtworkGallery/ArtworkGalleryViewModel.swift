// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-050): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ArtworkGalleryViewModel {
    let page: StubPage
    let releaseID: GameReleaseID?

    private let router: AppRouter
    private let artwork: any ArtworkRepository

    init(
        router: AppRouter,
        artwork: any ArtworkRepository,
        releaseID: GameReleaseID? = nil
    ) {
        self.router = router
        self.artwork = artwork
        self.releaseID = releaseID
        page = StubPage(
            id: "page.artworkGallery",
            title: String(localized: "Artwork viewer"),
            systemImage: "photo.on.rectangle",
            summary: String(localized: "Browse artwork for the selected game and console."),
            plannedWork: [
                String(localized: "Swipe between front/back covers, media scans, and screenshots"),
                String(localized: "Zoom while preserving image proportions"),
                String(localized: "Optional regional cover preference; deliberate video playback when a source is available")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
