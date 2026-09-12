// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

@MainActor
struct DesignContractTests {
    private let first = GameReleaseID(gameID: GameID(rawValue: 1), platformID: PlatformID(rawValue: 2))
    private let second = GameReleaseID(gameID: GameID(rawValue: 3), platformID: PlatformID(rawValue: 4))

    @Test
    func gameNavigationResetsMediaAndKeepsActionsOnTheSelectedRelease() throws {
        let router = AppRouter(showOnboarding: false)
        let model = GameDetailViewModel(
            router: router, catalog: ScaffoldCatalogRepository(), artwork: ScaffoldArtworkRepository(),
            library: ScaffoldPlayerLibraryRepository(), context: GameBrowsingContext(releases: [first, second])
        )
        model.selectHero(.video("synthetic-preview"))
        model.showPreviousGame()
        #expect(model.heroSelection == .video("synthetic-preview"))
        model.showNextGame()
        #expect(model.releaseID == second && model.heroSelection == .boxArt)
        let note = try #require(model.page.links.first { $0.id == "detail.note" })
        model.handle(note.intent)
        #expect(router.navigation(for: .discover).path == [.gameNote(second)])
        model.showNextGame()
        #expect(model.releaseID == second)
        model.selectHero(.image("synthetic-image"))
        model.showPreviousGame()
        #expect(model.releaseID == first && model.heroSelection == .boxArt)
    }

    @Test
    func invalidBrowsingPositionsCannotProduceInvalidDetails() {
        #expect(GameBrowsingContext(releases: []) == nil)
        #expect(GameBrowsingContext(releases: [first], selectedIndex: -1) == nil)
        #expect(GameBrowsingContext(releases: [first], selectedIndex: 1) == nil)
    }

    @Test
    func eraNavigationDoesNotInventProviderPlatformIDs() throws {
        let router = AppRouter(showOnboarding: false)
        let model = ComputerErasViewModel(router: router)
        let link = try #require(model.page.links.first { $0.id == "eras.windows9x" })
        model.handle(link.intent)
        #expect(router.navigation(for: .discover).path == [.gameCatalog(.computerEra(.windows9x))])
        let assignment = ComputerEraAssignment(releaseID: first, eras: [.windows9x, .windows2000XPVista])
        #expect(assignment.releaseID == first && assignment.eras.count == 2)
        #expect(ComputerEra.dos != .windows3x)
    }

    @Test
    func unimplementedEraMappingFailsExplicitly() async {
        await #expect(throws: ScaffoldError.notImplemented(.computerEras)) {
            _ = try await ScaffoldComputerEraRepository().assignments(in: .windows9x)
        }
    }

    @Test
    func paletteChangesDoNotOverrideSystemAppearance() {
        let theme = ThemeState()
        let model = AppearanceViewModel(router: AppRouter(showOnboarding: false), theme: theme)
        #expect(model.preferences.appearance == .system)
        model.setPalette(.ocean)
        #expect(theme.preferences.palette == .ocean && theme.preferences.appearance == .system)
        model.setAppearance(.dark)
        #expect(theme.preferences.palette == .ocean && theme.preferences.appearance == .dark)
        model.setAppearance(.system)
        #expect(theme.preferences.appearance == .system)
    }
}
