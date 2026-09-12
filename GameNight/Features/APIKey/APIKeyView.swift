// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct APIKeyView: View {
    @State private var viewModel: APIKeyViewModel
    @State private var confirmRemoval = false
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: APIKeyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var model = viewModel

        Form {
            Section {
                switch viewModel.storedKeyState {
                case .unknown:
                    Label("Key status unavailable", systemImage: "key")
                case .missing:
                    Label("No API key saved", systemImage: "key")
                case .stored:
                    Label("API key saved on this device", systemImage: "key.fill")
                }

                SecureField("MobyGames API key", text: $model.draftKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .privacySensitive()
                    .disabled(viewModel.isBusy)
                    .accessibilityIdentifier("connection.key")

                Button(viewModel.storedKeyState == .stored ? "Replace key" : "Save key") {
                    viewModel.requestSave()
                }
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("connection.save")
            } header: {
                Text("Your API key")
            } footer: {
                Text("Stored in this device's Keychain. It is not synced through iCloud Keychain or included in library exports.")
            }

            Section {
                Button("Check connection") { viewModel.requestCheck() }
                    .disabled(!viewModel.canCheck)
                    .accessibilityIdentifier("connection.check")

                if !viewModel.draftKey.isEmpty {
                    Text("Save your key before checking the connection.")
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if let operation = viewModel.operation {
                    HStack {
                        ProgressView()
                        Text(progressTitle(for: operation))
                    }
                    if operation == .check {
                        Button("Cancel check", role: .cancel) { viewModel.cancelCheck() }
                    }
                }

                if let feedback = viewModel.feedback {
                    Label(feedback.message, systemImage: feedback.isError ? "exclamationmark.circle" : "checkmark.circle")
                        .foregroundStyle(AppTheme.textPrimary)
                        .accessibilityIdentifier("connection.feedback")
                }

                if viewModel.storedKeyState == .unknown && !viewModel.isBusy {
                    Button("Retry reading key") { viewModel.activate() }
                }
            } footer: {
                Text("A connection check sends a request to MobyGames. Your Backlog, Shortlist, and notes are not sent.")
            }

            if viewModel.storedKeyState == .stored {
                Section {
                    Button("Remove API key", role: .destructive) { confirmRemoval = true }
                        .disabled(!viewModel.canRemove)
                        .accessibilityIdentifier("connection.remove")
                }
            }
        }
        .navigationTitle("MobyGames connection")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("page.apiKey")
        .confirmationDialog("Remove the saved API key?", isPresented: $confirmRemoval, titleVisibility: .visible) {
            Button("Remove key", role: .destructive) { viewModel.requestRemoval() }
        } message: {
            Text("Your saved games and preferences will remain on this device.")
        }
        .onAppear { if scenePhase == .active { viewModel.activate() } }
        .task(id: viewModel.operation) { await viewModel.executePendingOperation() }
        .onDisappear { viewModel.deactivate() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.activate()
            } else {
                confirmRemoval = false
                viewModel.deactivate()
            }
        }
    }

    private func progressTitle(for operation: APIKeyViewModel.Operation) -> String {
        switch operation {
        case .load: String(localized: "Reading key status…")
        case .save: String(localized: "Saving key…")
        case .remove: String(localized: "Removing key…")
        case .check: String(localized: "Checking connection…")
        }
    }
}
