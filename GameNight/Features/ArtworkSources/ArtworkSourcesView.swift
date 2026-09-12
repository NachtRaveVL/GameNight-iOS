// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ArtworkSourcesView: View {
    @State private var viewModel: ArtworkSourcesViewModel

    init(viewModel: ArtworkSourcesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
