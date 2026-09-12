// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ConsoleCatalogView: View {
    @State private var viewModel: ConsoleCatalogViewModel

    init(viewModel: ConsoleCatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
