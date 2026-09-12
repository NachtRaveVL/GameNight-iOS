// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct GameNightView: View {
    @State private var viewModel: GameNightViewModel

    init(viewModel: GameNightViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
