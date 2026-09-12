// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-023): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class APIKeyViewModel {
    let page: StubPage

    private let router: AppRouter
    private let credentials: any CredentialStore

    init(
        router: AppRouter,
        credentials: any CredentialStore
    ) {
        self.router = router
        self.credentials = credentials
        page = StubPage(
            id: "page.apiKey",
            title: String(localized: "MobyGames connection"),
            systemImage: "key",
            summary: String(localized: "Bring your own MobyGames API key. Entry is not implemented yet."),
            plannedWork: [
                String(localized: "Device-only Keychain storage; never preferences or export files"),
                String(localized: "Explicit connection check with safe errors"),
                String(localized: "The provider receives the requests needed to retrieve its catalog")
            ],
            links: []
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
