// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ArtworkGalleryView: View {
    @State private var viewModel: ArtworkGalleryViewModel

    init(viewModel: ArtworkGalleryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
