// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

/// Stateless rendering primitive. Its owning feature supplies all state and intents.
struct WorkInProgressView: View {
    let page: StubPage
    let onAction: @MainActor (NavigationIntent) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                Label("Work in progress", systemImage: "hammer")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Label(page.title, systemImage: page.systemImage)
                    .font(.title.weight(.bold))
                    .accessibilityAddTraits(.isHeader)

                Text(page.summary)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Text("Planned for this screen")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(page.plannedWork, id: \.self) { item in
                        Label(item, systemImage: "circle.dashed")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if !page.links.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                        Text("Explore the app structure")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(page.links) { link in
                            Button {
                                onAction(link.intent)
                            } label: {
                                Label(link.title, systemImage: link.systemImage)
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier(link.id)
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.large)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(page.id)
    }
}
