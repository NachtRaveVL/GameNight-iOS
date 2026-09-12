// SPDX-License-Identifier: GPL-3.0-or-later

import Observation

@MainActor
@Observable
final class TabNavigationState {
    var path: [AppRoute] = []
}

/// Presentation state only; repositories and business decisions do not live here.
@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .discover
    var sheet: AppSheet?
    var sheetPath: [AppRoute] = []

    private let discover = TabNavigationState()
    private let explore = TabNavigationState()
    private let backlog = TabNavigationState()
    private let played = TabNavigationState()
    private let profile = TabNavigationState()

    init(showOnboarding: Bool = false) {
        sheet = showOnboarding ? .onboarding : nil
    }

    func navigation(for tab: AppTab) -> TabNavigationState {
        switch tab {
        case .discover: discover
        case .explore: explore
        case .backlog: backlog
        case .played: played
        case .profile: profile
        }
    }

    func perform(_ intent: NavigationIntent) {
        switch intent {
        case .push(let route):
            if sheet != nil {
                sheetPath.append(route)
            } else {
                navigation(for: selectedTab).path.append(route)
            }
        case .present(let sheet):
            sheetPath.removeAll()
            self.sheet = sheet
        case .dismissSheet:
            dismissSheet()
        }
    }

    func dismissSheet() {
        sheet = nil
        sheetPath.removeAll()
    }

    /// Handles interactive dismissal as well as the explicit Close action.
    func sheetDidDismiss() {
        sheetPath.removeAll()
    }
}
