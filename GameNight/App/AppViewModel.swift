// SPDX-License-Identifier: GPL-3.0-or-later

import Observation

/// Owns long-lived presentation state and assembles the five root features.
@MainActor
@Observable
final class AppViewModel {
    let router: AppRouter
    let theme: ThemeState
    let screens: AppScreenFactory
    let discover: DiscoverViewModel
    let explore: ExploreViewModel
    let backlog: BacklogViewModel
    let played: PlayedViewModel
    let profile: ProfileViewModel

    init(
        dependencies: AppDependencies,
        showOnboarding: Bool = false,
        themePreferences: ThemePreferences = ThemePreferences()
    ) {
        let theme = ThemeState(preferences: themePreferences)
        self.theme = theme
        let router = AppRouter(showOnboarding: showOnboarding)
        self.router = router
        screens = AppScreenFactory(dependencies: dependencies, router: router, theme: theme)
        discover = DiscoverViewModel(
            router: router,
            catalog: dependencies.catalog,
            recommendations: dependencies.recommendations,
            library: dependencies.library
        )
        explore = ExploreViewModel(router: router, catalog: dependencies.catalog, library: dependencies.library)
        backlog = BacklogViewModel(router: router, library: dependencies.library)
        played = PlayedViewModel(router: router, library: dependencies.library)
        profile = ProfileViewModel(router: router, library: dependencies.library)
    }

    func dismissSheet() {
        router.dismissSheet()
    }

    func sheetDidDismiss() {
        router.sheetDidDismiss()
    }
}
