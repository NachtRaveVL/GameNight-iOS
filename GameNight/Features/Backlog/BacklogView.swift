// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct BacklogView: View {
    @State private var viewModel: BacklogViewModel

    init(viewModel: BacklogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
