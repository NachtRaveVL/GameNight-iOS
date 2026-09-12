// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct TonightView: View {
    @State private var viewModel: TonightViewModel

    init(viewModel: TonightViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
