// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-053): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class AppearanceViewModel {
    let page: StubPage
    private let router: AppRouter
    private let theme: ThemeState
    var preferences: ThemePreferences { theme.preferences }

    init(router: AppRouter, theme: ThemeState) {
        self.router = router
        self.theme = theme
        page = StubPage(
            id: "page.appearance",
            title: String(localized: "Appearance"),
            systemImage: "paintpalette",
            summary: String(localized: "Follow your device appearance, or choose your own."),
            plannedWork: [
                String(localized: "System, Light, and Dark appearance independent of palette"),
                String(localized: "Coordinated palettes across the app and its sheets"),
                String(localized: "Accessible contrast, text sizing, and reduced motion")
            ],
            links: []
        )
    }

    // In-memory intents for the future controls; never claim to persist settings yet.
    func setAppearance(_ appearance: AppAppearance) { theme.preferences.appearance = appearance }
    func setPalette(_ palette: AppPalette) { theme.preferences.palette = palette }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
