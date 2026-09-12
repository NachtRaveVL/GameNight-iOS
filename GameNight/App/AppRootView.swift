// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct AppRootView: View {
    let viewModel: AppViewModel

    var body: some View {
        @Bindable var router = viewModel.router

        TabView(selection: $router.selectedTab) {
            Tab("Discover", systemImage: "sparkles", value: AppTab.discover) {
                tabStack(.discover) {
                    DiscoverView(viewModel: viewModel.discover)
                }
            }

            Tab("Explore", systemImage: "magnifyingglass", value: AppTab.explore) {
                tabStack(.explore) {
                    ExploreView(viewModel: viewModel.explore)
                }
            }

            Tab("Backlog", systemImage: "list.bullet", value: AppTab.backlog) {
                tabStack(.backlog) {
                    BacklogView(viewModel: viewModel.backlog)
                }
            }

            Tab("Played", systemImage: "checkmark.circle", value: AppTab.played) {
                tabStack(.played) {
                    PlayedView(viewModel: viewModel.played)
                }
            }

            Tab("Profile", systemImage: "person.crop.circle", value: AppTab.profile) {
                tabStack(.profile) {
                    ProfileView(viewModel: viewModel.profile)
                }
            }
        }
        .sheet(item: $router.sheet, onDismiss: viewModel.sheetDidDismiss) { sheet in
            AppSheetView(sheet: sheet, viewModel: viewModel)
        }
    }

    private func tabStack<Content: View>(
        _ tab: AppTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        TabNavigationView(navigation: viewModel.router.navigation(for: tab), screens: viewModel.screens) {
            content()
        }
    }
}

#Preview("App shell") {
    AppRootView(viewModel: AppViewModel(dependencies: .scaffold(), showOnboarding: false))
}

#Preview("Dark / large text") {
    AppRootView(viewModel: AppViewModel(dependencies: .scaffold(), showOnboarding: false))
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}
