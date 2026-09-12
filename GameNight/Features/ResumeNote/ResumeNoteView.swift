// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct ResumeNoteView: View {
    @State private var viewModel: ResumeNoteViewModel

    init(viewModel: ResumeNoteViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
