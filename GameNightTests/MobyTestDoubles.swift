// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import GameNight

actor TestMobyClock: MobyRequestClock {
    private var instant: TimeInterval = 0
    private(set) var sleeps: [TimeInterval] = []
    var cancelOnSleep = false

    func now() -> TimeInterval { instant }

    func sleep(for seconds: TimeInterval) async throws {
        try Task.checkCancellation()
        if cancelOnSleep { throw CancellationError() }
        sleeps.append(seconds)
        instant += seconds
        await Task.yield()
        try Task.checkCancellation()
    }

    func cancelNextSleep() {
        cancelOnSleep = true
    }
}

actor TestCredentialStore: CredentialStore {
    private var key: String?

    init(key: String? = "synthetic+secret") { self.key = key }

    func mobyGamesAPIKey() -> String? { key }
    func setMobyGamesAPIKey(_ key: String) { self.key = key }
    func deleteMobyGamesAPIKey() { key = nil }
}

actor ScriptedMobyTransport: HTTPTransport {
    private var responses: [Result<HTTPResponse, URLError>]
    private(set) var requests: [URLRequest] = []

    init(_ responses: [Result<HTTPResponse, URLError>]) { self.responses = responses }

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        requests.append(request)
        guard !responses.isEmpty else { throw URLError(.badServerResponse) }
        return try responses.removeFirst().get()
    }
}

actor OverlappingMobyTransport: HTTPTransport {
    private var active = 0
    private(set) var peak = 0

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        active += 1
        peak = max(peak, active)
        defer { active -= 1 }
        guard let component = request.url?.lastPathComponent, let id = Int(component) else {
            throw URLError(.badURL)
        }
        // Force completion order to differ from input order; sleep is cancellable.
        try await Task.sleep(for: .milliseconds(id == 1 ? 80 : 10))
        let data = Data("{\"game_id\":\(id),\"title\":\"Synthetic game\"}".utf8)
        return HTTPResponse(statusCode: 200, data: data)
    }
}
