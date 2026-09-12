// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation

@MainActor
@Observable
final class APIKeyViewModel {
    enum Operation: Equatable {
        case load
        case save
        case remove
        case check
    }

    enum StoredKeyState {
        case unknown
        case missing
        case stored
    }

    struct Feedback {
        let message: String
        let isError: Bool
    }

    var draftKey = "" {
        didSet {
            if draftKey != oldValue {
                connectionVerified = false
                feedback = nil
            }
        }
    }
    private(set) var storedKeyState: StoredKeyState = .unknown
    private(set) var operation: Operation?
    private(set) var feedback: Feedback?
    private(set) var connectionVerified = false

    var isBusy: Bool { operation != nil }
    var canSave: Bool { !isBusy && !draftKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var canCheck: Bool { !isBusy && storedKeyState == .stored && draftKey.isEmpty }
    var canRemove: Bool { !isBusy && storedKeyState == .stored }

    private let credentials: any CredentialStore
    private let connection: any MobyConnectionChecking
    private var generation = 0
    private var executingGeneration: Int?

    init(credentials: any CredentialStore, connection: any MobyConnectionChecking) {
        self.credentials = credentials
        self.connection = connection
    }

    func activate() {
        guard !isBusy, storedKeyState == .unknown else { return }
        request(.load)
    }

    func requestSave() {
        guard canSave else { return }
        request(.save)
    }

    func requestCheck() {
        guard canCheck else { return }
        request(.check)
    }

    func requestRemoval() {
        guard canRemove else { return }
        request(.remove)
    }

    func cancelCheck() {
        guard operation == .check else { return }
        generation &+= 1
        operation = nil
        connectionVerified = false
        feedback = nil
    }

    /// Called on disappearance/backgrounding. SwiftUI cancels the task when its ID changes.
    /// Re-entry re-reads storage in case a non-cancellable Security call already committed.
    func deactivate() {
        generation &+= 1
        operation = nil
        draftKey = ""
        feedback = nil
        connectionVerified = false
        storedKeyState = .unknown
    }

    /// Run from the view's .task(id:); no unstructured task survives the screen lifecycle.
    func executePendingOperation() async {
        guard let operation else { return }
        let ticket = generation
        guard executingGeneration != ticket else { return }
        executingGeneration = ticket
        defer {
            if generation == ticket { self.operation = nil }
            if executingGeneration == ticket { executingGeneration = nil }
        }
        do {
            try Task.checkCancellation()
            switch operation {
            case .load:
                let exists = try await credentials.mobyGamesAPIKey() != nil
                guard generation == ticket, !Task.isCancelled else { return }
                storedKeyState = exists ? .stored : .missing
            case .save:
                let key = try MobyAPIKey.normalized(draftKey)
                try await credentials.setMobyGamesAPIKey(key)
                guard generation == ticket else { return }
                draftKey = ""
                storedKeyState = .stored
                connectionVerified = false
                feedback = Feedback(message: String(localized: "API key saved. Connection has not been checked."), isError: false)
            case .remove:
                try await credentials.deleteMobyGamesAPIKey()
                guard generation == ticket else { return }
                draftKey = ""
                storedKeyState = .missing
                connectionVerified = false
                feedback = Feedback(message: String(localized: "API key removed. Your library is unchanged."), isError: false)
            case .check:
                try await connection.checkConnection()
                guard generation == ticket, !Task.isCancelled else { return }
                connectionVerified = true
                feedback = Feedback(message: String(localized: "Connected to MobyGames."), isError: false)
            }
        } catch {
            guard generation == ticket else { return }
            connectionVerified = false
            if error is CancellationError || Task.isCancelled { return }
            feedback = Feedback(message: safeMessage(for: error), isError: true)
        }
    }

    private func request(_ operation: Operation) {
        generation &+= 1
        feedback = nil
        connectionVerified = false
        self.operation = operation
    }

    private func safeMessage(for error: any Error) -> String {
        if let error = error as? CredentialStoreError, let message = error.errorDescription { return message }
        if let error = error as? MobyAPIError, let message = error.errorDescription { return message }
        // Never display raw NSError/URL/response descriptions, which can contain credentials.
        return String(localized: "The operation could not be completed. Please try again.")
    }
}
