// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct RecommendationTuningView: View {
    @State private var viewModel: RecommendationTuningViewModel

    init(viewModel: RecommendationTuningViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        WorkInProgressView(page: viewModel.page, onAction: viewModel.handle)
    }
}
