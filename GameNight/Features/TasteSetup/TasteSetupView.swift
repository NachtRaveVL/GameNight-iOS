// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct TasteSetupView: View {
    @State private var viewModel: TasteSetupViewModel

    init(viewModel: TasteSetupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
