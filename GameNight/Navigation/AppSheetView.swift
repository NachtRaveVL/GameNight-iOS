// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

/// Modals have their own typed path and cannot accidentally push behind the sheet.
struct AppSheetView: View {
    let sheet: AppSheet
    let viewModel: AppViewModel

    var body: some View {
        @Bindable var router = viewModel.router

        NavigationStack(path: $router.sheetPath) {
            viewModel.screens.makeSheet(sheet)
                .navigationDestination(for: AppRoute.self) { route in
                    viewModel.screens.makeRoute(route)
                        .id(route)
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Close", action: viewModel.dismissSheet)
                            .accessibilityIdentifier("sheet.close")
                    }
                }
        }
    }
}
