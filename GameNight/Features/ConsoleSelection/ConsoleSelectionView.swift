// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ConsoleSelectionView: View {
    @State private var viewModel: ConsoleSelectionViewModel

    init(viewModel: ConsoleSelectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
