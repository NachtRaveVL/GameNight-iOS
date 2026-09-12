// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct GameNoteView: View {
    @State private var viewModel: GameNoteViewModel

    init(viewModel: GameNoteViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
