// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ShortlistView: View {
    @State private var viewModel: ShortlistViewModel

    init(viewModel: ShortlistViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
