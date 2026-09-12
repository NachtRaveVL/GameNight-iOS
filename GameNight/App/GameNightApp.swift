// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

@main
@MainActor
struct GameNightApp: App {
    @State private var viewModel: AppViewModel

    init() {
        _viewModel = State(initialValue: AppViewModel(dependencies: .live()))
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(viewModel: viewModel)
        }
    }
}
