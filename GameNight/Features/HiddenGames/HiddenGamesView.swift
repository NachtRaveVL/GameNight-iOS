// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct HiddenGamesView: View {
    @State private var viewModel: HiddenGamesViewModel

    init(viewModel: HiddenGamesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
