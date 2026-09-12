// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct APIKeyView: View {
    @State private var viewModel: APIKeyViewModel

    init(viewModel: APIKeyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
