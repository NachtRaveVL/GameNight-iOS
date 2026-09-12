// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-022): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class GameDetailViewModel {
    let page: StubPage
    let releaseID: GameReleaseID?

    private let router: AppRouter
    private let catalog: any CatalogRepository
    private let artwork: any ArtworkRepository
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        artwork: any ArtworkRepository,
        library: any PlayerLibraryRepository,
        releaseID: GameReleaseID? = nil
    ) {
        self.router = router
        self.catalog = catalog
        self.artwork = artwork
        self.library = library
        self.releaseID = releaseID
        page = StubPage(
            id: "page.gameDetail",
            title: String(localized: "Game overview"),
            systemImage: "rectangle.portrait",
            summary: String(localized: "The box-art-led overview. No game is selected in this preview."),
            plannedWork: [
                String(localized: "Full box art at its original proportions with a blurred surround"),
                String(localized: "Swipe between games in the originating list; preserve the edge Back gesture"),
                String(localized: "Synopsis, selected console, and explicit personal actions"),
                String(localized: "Separate artwork viewer and recommendations below the overview")
            ],
            links: [
                StubLink(
                    id: "detail.artwork",
                    title: String(localized: "Artwork viewer stub"),
                    systemImage: "photo.on.rectangle",
                    intent: .present(.artwork(releaseID))
                ),
                StubLink(
                    id: "detail.note",
                    title: String(localized: "Where I left off"),
                    systemImage: "bookmark",
                    intent: .push(.resumeNote(releaseID))
                )
            ]
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
