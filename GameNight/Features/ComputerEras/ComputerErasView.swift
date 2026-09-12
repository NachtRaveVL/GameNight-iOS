// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ComputerErasView: View {
    @State private var viewModel: ComputerErasViewModel

    init(viewModel: ComputerErasViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
