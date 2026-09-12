// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct GameCatalogView: View {
    @State private var viewModel: GameCatalogViewModel

    init(viewModel: GameCatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
