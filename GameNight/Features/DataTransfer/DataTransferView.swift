// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct DataTransferView: View {
    @State private var viewModel: DataTransferViewModel

    init(viewModel: DataTransferViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
