// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct AppearanceView: View {
    @State private var viewModel: AppearanceViewModel

    init(viewModel: AppearanceViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
