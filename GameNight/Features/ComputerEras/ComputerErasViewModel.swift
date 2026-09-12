// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

/// TODO(GN-024): Replace the page stub with feature state and use-case intents.
@MainActor
@Observable
final class ComputerErasViewModel {
    let page: StubPage
    private let router: AppRouter
    init(router: AppRouter) {
        self.router = router
        page = StubPage(
            id: "page.computerEras",
            title: String(localized: "Computer eras"),
            systemImage: "desktopcomputer",
            summary: String(localized: "Browse the gaming environments you enjoy."),
            plannedWork: [
                String(localized: "DOS and Windows 3.x remain distinct"),
                String(localized: "Curated Windows, Mac, and Linux collections may overlap"),
                String(localized: "Era labels never imply operating-system compatibility")
            ],
            links: ComputerEra.allCases.map { era in
                StubLink(
                    id: "eras." + era.rawValue,
                    title: era.title,
                    systemImage: "desktopcomputer",
                    intent: .push(.gameCatalog(.computerEra(era)))
                )
            }
        )
    }

    func handle(_ intent: NavigationIntent) {
        router.perform(intent)
    }
}
