// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

private actor ConnectionCredentials: CredentialStore {
    var key: String?
    var failure: CredentialStoreError?
    private(set) var writes = 0

    init(key: String? = nil, failure: CredentialStoreError? = nil) {
        self.key = key
        self.failure = failure
    }

    func mobyGamesAPIKey() throws -> String? {
        if let failure { throw failure }
        return key
    }
    func setMobyGamesAPIKey(_ key: String) throws {
        if let failure { throw failure }
        self.key = key
        writes += 1
    }
    func deleteMobyGamesAPIKey() throws {
        if let failure { throw failure }
        key = nil
    }
}

private actor ConnectionProbe: MobyConnectionChecking {
    private(set) var calls = 0
    let failure: MobyAPIError?
    init(failure: MobyAPIError? = nil) { self.failure = failure }
    func checkConnection() throws {
        calls += 1
        if let failure { throw failure }
    }
}

/// Deliberately ignores cancellation to verify that stale results cannot revive a cancelled UI.
private actor SuspendedConnectionProbe: MobyConnectionChecking {
    private var continuation: CheckedContinuation<Void, Never>?
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private var started = false
    func checkConnection() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            started = true
            startWaiters.forEach { $0.resume() }
            startWaiters.removeAll()
        }
    }
    func waitUntilStarted() async {
        if started { return }
        await withCheckedContinuation { startWaiters.append($0) }
    }
    func finish() { continuation?.resume(); continuation = nil }
}

@MainActor
struct ConnectionFlowTests {
    @Test
    func loadAndSaveNeverContactMobyGamesOrRevealTheStoredKey() async throws {
        let store = ConnectionCredentials(key: "old+synthetic")
        let checker = ConnectionProbe()
        let model = APIKeyViewModel(credentials: store, connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        #expect(model.storedKeyState == .stored && model.draftKey.isEmpty)
        #expect(await checker.calls == 0)
        model.draftKey = "  new+synthetic/= \n"
        model.requestSave()
        await model.executePendingOperation(id: model.operationID)
        #expect(try await store.mobyGamesAPIKey() == "new+synthetic/=")
        #expect(model.draftKey.isEmpty && !model.connectionVerified)
        #expect(await checker.calls == 0)
        #expect(await store.writes == 1)
        model.requestCheck()
        await model.executePendingOperation(id: model.operationID)
        #expect(model.connectionVerified && !model.isBusy)
        #expect(await checker.calls == 1)
    }

    @Test
    func unsavedDraftCannotBeMistakenForTheCheckedKey() async {
        let checker = ConnectionProbe()
        let model = APIKeyViewModel(credentials: ConnectionCredentials(key: "saved"), connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.draftKey = "different"
        model.requestCheck()
        await model.executePendingOperation(id: model.operationID)
        #expect(await checker.calls == 0)
        #expect(!model.connectionVerified)
    }

    @Test
    func failedReplacementDoesNotClaimSuccess() async throws {
        let store = ConnectionCredentials(key: "original", failure: .deviceLocked)
        let model = APIKeyViewModel(credentials: store, connection: ConnectionProbe())
        model.draftKey = "replacement"
        model.requestSave()
        await model.executePendingOperation(id: model.operationID)
        #expect(model.feedback?.isError == true)
        #expect(await store.key == "original")
        #expect(await store.writes == 0)
        #expect(!model.connectionVerified && !model.isBusy)
    }

    @Test
    func removingKeyIsExplicitAndDoesNotCheckTheNetwork() async throws {
        let store = ConnectionCredentials(key: "synthetic")
        let checker = ConnectionProbe()
        let model = APIKeyViewModel(credentials: store, connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.requestRemoval()
        await model.executePendingOperation(id: model.operationID)
        #expect(try await store.mobyGamesAPIKey() == nil)
        #expect(model.storedKeyState == .missing && !model.connectionVerified)
        #expect(await checker.calls == 0)
    }

    @Test
    func failedCheckKeepsTheSavedKeyAndAllowsRetry() async throws {
        let store = ConnectionCredentials(key: "synthetic")
        let checker = ConnectionProbe(failure: .unauthorized)
        let model = APIKeyViewModel(credentials: store, connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.requestCheck()
        await model.executePendingOperation(id: model.operationID)
        #expect(model.feedback?.isError == true && model.canCheck)
        #expect(try await store.mobyGamesAPIKey() == "synthetic")
        #expect(!model.connectionVerified)
    }

    @Test
    func cancelledOrDisappearedScreenIgnoresLateSuccess() async {
        let checker = SuspendedConnectionProbe()
        let model = APIKeyViewModel(credentials: ConnectionCredentials(key: "synthetic"), connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.requestCheck()
        let operation = Task { await model.executePendingOperation(id: model.operationID) }
        await checker.waitUntilStarted()
        model.cancelCheck()
        model.draftKey = "unsaved-secret"
        model.deactivate()
        await checker.finish()
        await operation.value
        #expect(!model.connectionVerified && model.feedback == nil && model.draftKey.isEmpty)
        #expect(model.storedKeyState == .unknown && !model.isBusy)
    }

    @Test
    func cancelledScheduledTaskDoesNotConsumePendingLoad() async {
        let model = APIKeyViewModel(credentials: ConnectionCredentials(key: "synthetic"), connection: ConnectionProbe())
        model.activate()
        let staleTask = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            await model.executePendingOperation(id: model.operationID)
        }
        await staleTask.value
        #expect(model.operation == .load)
        await model.executePendingOperation(id: model.operationID)
        #expect(model.storedKeyState == .stored)
    }

    @Test
    func rapidCancelAndRetryHasANewTaskIdentity() async {
        let checker = ConnectionProbe()
        let model = APIKeyViewModel(credentials: ConnectionCredentials(key: "synthetic"), connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.requestCheck()
        let cancelledID = model.operationID
        // No suspension: SwiftUI may observe only the final .check operation kind.
        model.cancelCheck()
        model.requestCheck()
        let retryID = model.operationID
        #expect(retryID != cancelledID)
        await model.executePendingOperation(id: cancelledID)
        #expect(model.operation == .check)
        #expect(await checker.calls == 0)
        await model.executePendingOperation(id: retryID)
        #expect(model.connectionVerified && !model.isBusy)
        #expect(await checker.calls == 1)
    }

    @Test
    func lateCompletionDoesNotClearReplacementRequest() async {
        let checker = SuspendedConnectionProbe()
        let model = APIKeyViewModel(credentials: ConnectionCredentials(key: "synthetic"), connection: checker)
        model.activate()
        await model.executePendingOperation(id: model.operationID)
        model.requestCheck()
        let oldID = model.operationID
        let oldTask = Task { await model.executePendingOperation(id: oldID) }
        await checker.waitUntilStarted()
        model.deactivate()
        model.activate()
        let replacementID = model.operationID
        await checker.finish()
        await oldTask.value
        #expect(model.operation == .load && model.operationID == replacementID)
        #expect(!model.connectionVerified && model.feedback == nil)
        await model.executePendingOperation(id: replacementID)
        #expect(model.storedKeyState == .stored && !model.isBusy)
    }

    @Test
    func invalidKeyInputPreservesSpecialCharactersButRejectsControls() throws {
        #expect(try MobyAPIKey.normalized(" +a/b=c&d% ") == "+a/b=c&d%")
        for invalid in [" \n", "abc\ndef", "abc\u{0}def", String(repeating: "a", count: 4097)] {
            #expect(throws: CredentialStoreError.invalidKey) { _ = try MobyAPIKey.normalized(invalid) }
        }
    }
}
