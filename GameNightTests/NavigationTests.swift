// SPDX-License-Identifier: GPL-3.0-or-later

import Testing
@testable import GameNight

@MainActor
struct NavigationTests {
    @Test
    func switchingTabsPreservesIndependentHistories() {
        let router = AppRouter(showOnboarding: false)
        router.perform(.push(.gameDetail(nil)))
        router.selectedTab = .backlog
        router.perform(.push(.shelves))
        router.selectedTab = .discover

        #expect(router.navigation(for: .discover).path == [.gameDetail(nil)])
        #expect(router.navigation(for: .backlog).path == [.shelves])
        #expect(router.navigation(for: .explore).path.isEmpty)
    }

    @Test
    func modalNavigationDoesNotPushBehindTheSheet() {
        let router = AppRouter()
        router.perform(.push(.consoleSelection))

        #expect(router.sheet == .onboarding)
        #expect(router.sheetPath == [.consoleSelection])
        #expect(router.navigation(for: .discover).path.isEmpty)

        router.dismissSheet()
        #expect(router.sheet == nil)
        #expect(router.sheetPath.isEmpty)
    }

    @Test
    func interactiveDismissalClearsModalHistory() {
        let router = AppRouter()
        router.perform(.push(.tasteSetup))
        router.sheet = nil
        router.sheetDidDismiss()
        router.perform(.present(.onboarding))

        #expect(router.sheetPath.isEmpty)
    }

    @Test
    func detailPreservesReleaseIdentityWhenOpeningArtwork() throws {
        let release = GameReleaseID(gameID: GameID(rawValue: 42), platformID: PlatformID(rawValue: 7))
        let router = AppRouter(showOnboarding: false)
        let model = GameDetailViewModel(
            router: router,
            catalog: ScaffoldCatalogRepository(),
            artwork: ScaffoldArtworkRepository(),
            library: ScaffoldPlayerLibraryRepository(),
            releaseID: release
        )
        let link = try #require(model.page.links.first { $0.id == "detail.artwork" })
        model.handle(link.intent)

        #expect(router.sheet == .artwork(release))
    }

    @Test
    func welcomeContinueExposesTheShell() throws {
        let router = AppRouter()
        let model = OnboardingViewModel(router: router, library: ScaffoldPlayerLibraryRepository())
        let link = try #require(model.page.links.first { $0.id == "onboarding.continue" })
        model.handle(link.intent)

        #expect(router.sheet == nil)
        #expect(router.selectedTab == .discover)
    }
}
