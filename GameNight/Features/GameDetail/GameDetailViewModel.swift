// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-022): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class GameDetailViewModel {
    enum HeroSelection: Equatable {
        case boxArt
        case image(String)
        case video(String)
    }

    var page: StubPage { makePage() }
    private(set) var context: GameBrowsingContext?
    private(set) var heroSelection: HeroSelection = .boxArt
    var releaseID: GameReleaseID? { context?.releaseID }
    var hasPreviousGame: Bool { context?.hasPrevious == true }
    var hasNextGame: Bool { context?.hasNext == true }

    private let router: AppRouter
    private let catalog: any CatalogRepository
    private let artwork: any ArtworkRepository
    private let library: any PlayerLibraryRepository

    init(
        router: AppRouter,
        catalog: any CatalogRepository,
        artwork: any ArtworkRepository,
        library: any PlayerLibraryRepository,
        context: GameBrowsingContext? = nil
    ) {
        self.router = router
        self.catalog = catalog
        self.artwork = artwork
        self.library = library
        self.context = context
    }

    // Media IDs will come from the selected release's loaded previews (GN-022/GN-050).
    func selectHero(_ selection: HeroSelection) {
        guard context != nil else { return }
        heroSelection = selection
    }

    func showNextGame() {
        guard context?.moveNext() == true else { return }
        heroSelection = .boxArt
    }

    func showPreviousGame() {
        guard context?.movePrevious() == true else { return }
        heroSelection = .boxArt
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }

    private func makePage() -> StubPage {
        StubPage(
            id: "page.gameDetail",
            title: String(localized: "Game overview"),
            systemImage: "rectangle.portrait",
            summary: String(localized: "Box art, previews, and possibilities. The overview is still a stub."),
            plannedWork: [
                String(localized: "Full box art by default; thumbnails select images or video in the hero"),
                String(localized: "Swipe between games in the originating list; preserve the edge Back gesture"),
                String(localized: "Title, release selector, Backlog, Shortlist, and optional completion beneath the hero"),
                String(localized: "Readable overview and related games before expandable facts and credits")
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
                    title: String(localized: "Your note"),
                    systemImage: "bookmark",
                    intent: .push(.gameNote(releaseID))
                )
            ]
        )
    }
}
