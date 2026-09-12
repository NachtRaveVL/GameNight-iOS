// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct GameDetailView: View {
    @State private var viewModel: GameDetailViewModel

    init(viewModel: GameDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
