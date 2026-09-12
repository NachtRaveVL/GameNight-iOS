// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

/// A structural view binding a tab's navigation state; it owns no business logic.
struct TabNavigationView<Content: View>: View {
    @Bindable var navigation: TabNavigationState
    let screens: AppScreenFactory
    let content: Content

    init(
        navigation: TabNavigationState,
        screens: AppScreenFactory,
        @ViewBuilder content: () -> Content
    ) {
        self.navigation = navigation
        self.screens = screens
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            content
                .navigationDestination(for: AppRoute.self) { route in
                    screens.makeRoute(route)
                        .id(route)
                }
        }
    }
}
