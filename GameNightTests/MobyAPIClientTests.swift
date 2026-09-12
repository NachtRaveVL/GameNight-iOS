// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

struct MobyAPIClientTests {
    private var emptyPlatforms: HTTPResponse {
        HTTPResponse(statusCode: 200, data: Data(#"{"platforms":[]}"#.utf8))
    }

    @Test
    func absentCredentialsSendNoRequest() async {
        let transport = ScriptedMobyTransport([])
        let client = MobyAPIClient(credentials: TestCredentialStore(key: nil), transport: transport)
        await #expect(throws: MobyAPIError.missingAPIKey) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.isEmpty)
    }

    @Test
    func unimplementedKeychainIsExplicitlyUnavailable() async {
        let transport = ScriptedMobyTransport([])
        let client = MobyAPIClient(credentials: ScaffoldCredentialStore(), transport: transport)
        await #expect(throws: MobyAPIError.credentialStoreUnavailable) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.isEmpty)
    }

    @Test
    func rateLimitRetryHonorsCooldownAndUsesFreshCredentials() async throws {
        let clock = TestMobyClock()
        let credentials = TestCredentialStore()
        let transport = ScriptedMobyTransport([
            .success(HTTPResponse(statusCode: 429, data: Data(), retryAfter: "12")),
            .success(emptyPlatforms), .success(emptyPlatforms)
        ])
        let client = MobyAPIClient(credentials: credentials, transport: transport, clock: clock)
        _ = try await client.send(MobyRequests.platforms())
        #expect(await clock.now() >= 12)
        await credentials.setMobyGamesAPIKey("replacement+key")
        _ = try await client.send(MobyRequests.platforms())
        let last = try #require(await transport.requests.last?.url)
        let query = URLComponents(url: last, resolvingAgainstBaseURL: false)?.queryItems
        #expect(query?.first { $0.name == "api_key" }?.value == "replacement+key")
        #expect(await transport.requests.count == 3)
    }

    @Test
    func longServerCooldownIsReportedWithoutImmediateRetries() async {
        let transport = ScriptedMobyTransport([
            .success(HTTPResponse(statusCode: 429, data: Data(), retryAfter: "3600"))
        ])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport, clock: TestMobyClock())
        await #expect(throws: MobyAPIError.rateLimited(retryAfter: 3600)) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.count == 1)
    }

    @Test
    func transientServerRetriesAreBounded() async {
        let failure = HTTPResponse(statusCode: 503, data: Data())
        let transport = ScriptedMobyTransport([.success(failure), .success(failure), .success(failure)])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport, clock: TestMobyClock())
        await #expect(throws: MobyAPIError.httpStatus(503)) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.count == 3)
    }

    @Test
    func unauthorizedResponsesAreNotRetriedOrEchoed() async {
        let body = Data(#"{"message":"a response could echo a synthetic+secret"}"#.utf8)
        let transport = ScriptedMobyTransport([.success(HTTPResponse(statusCode: 401, data: body))])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport)
        await #expect(throws: MobyAPIError.unauthorized) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.count == 1)
        #expect(MobyAPIError.unauthorized.errorDescription?.contains("synthetic") == false)
    }

    @Test
    func malformedSuccessResponsesAreNotMistakenForEmptyData() async {
        let transport = ScriptedMobyTransport([.success(HTTPResponse(statusCode: 200, data: Data("{}".utf8)))])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport)
        await #expect(throws: MobyAPIError.decodingFailed) {
            _ = try await client.send(MobyRequests.platforms())
        }
    }

    @Test
    func cancellationWhileWaitingSendsNoExtraRequest() async throws {
        let clock = TestMobyClock()
        let transport = ScriptedMobyTransport([.success(emptyPlatforms)])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport, clock: clock)
        _ = try await client.send(MobyRequests.platforms())
        await clock.cancelNextSleep()
        await #expect(throws: CancellationError.self) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.count == 1)
    }

    @Test
    func transportCancellationIsNotRetried() async {
        let transport = ScriptedMobyTransport([.failure(URLError(.cancelled))])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport)
        await #expect(throws: CancellationError.self) {
            _ = try await client.send(MobyRequests.platforms())
        }
        #expect(await transport.requests.count == 1)
    }

    @Test
    func transientTransportFailureRetriesButOfflineErrorsStaySanitized() async throws {
        let transport = ScriptedMobyTransport([.failure(URLError(.timedOut)), .success(emptyPlatforms)])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport, clock: TestMobyClock())
        _ = try await client.send(MobyRequests.platforms())
        #expect(await transport.requests.count == 2)

        let offline = ScriptedMobyTransport([.failure(URLError(
            .notConnectedToInternet,
            userInfo: [NSLocalizedDescriptionKey: "https://example.invalid/?api_key=synthetic"]
        ))])
        let offlineClient = MobyAPIClient(credentials: TestCredentialStore(), transport: offline)
        await #expect(throws: MobyAPIError.transport(code: URLError.notConnectedToInternet.rawValue)) {
            _ = try await offlineClient.send(MobyRequests.platforms())
        }
        #expect(await offline.requests.count == 1)
    }

    @Test
    func permanentHTTPFailuresAndDisabledRetriesSendOnlyOnce() async {
        for (status, expected) in [(404, MobyAPIError.notFound), (422, .httpStatus(422)), (503, .httpStatus(503))] {
            let transport = ScriptedMobyTransport([.success(HTTPResponse(statusCode: status, data: Data()))])
            let client = MobyAPIClient(
                credentials: TestCredentialStore(), transport: transport, retryPolicy: .disabled
            )
            await #expect(throws: expected) {
                _ = try await client.send(MobyRequests.platforms())
            }
            #expect(await transport.requests.count == 1)
        }
    }

    @Test
    func catalogMapsProviderIdentityAndPreservesConsoleScopeAndOffset() async throws {
        let data = Data(#"""
        {"games":[{"game_id":42,"title":"Example","platforms":[
            {"platform_id":7,"platform_name":"Example console"}
        ]}]}
        """#.utf8)
        let transport = ScriptedMobyTransport([.success(HTTPResponse(statusCode: 200, data: data))])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport)
        let repository = MobyCatalogRepository(client: client)
        let page = try await repository.games(matching: CatalogQuery(
            title: "Example", scope: .myConsoles([PlatformID(rawValue: 7)]), offset: 100
        ))
        #expect(page.games.first?.id == GameID(rawValue: 42))
        #expect(page.games.first?.platformIDs == [PlatformID(rawValue: 7)])
        #expect(page.nextOffset == nil)
        let url = try #require(await transport.requests.first?.url)
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        #expect(query?.first { $0.name == "platform" }?.value == "7")
        #expect(query?.first { $0.name == "offset" }?.value == "100")
    }

    @Test
    func limiterSupportsNormalAndLegacyPacing() async throws {
        let clock = TestMobyClock()
        let limiter = MobyRateLimiter(clock: clock)
        try await limiter.waitForPermit()
        try await limiter.waitForPermit()
        #expect(await clock.now() == 5)

        let legacyClock = TestMobyClock()
        let legacy = MobyRateLimiter(tier: .legacyNonCommercial, clock: legacyClock)
        try await legacy.waitForPermit()
        try await legacy.waitForPermit()
        #expect(await legacyClock.now() == 10)
    }

    @Test
    func batchesOverlapWithinTheirBoundAndPreserveInputOrder() async throws {
        let transport = OverlappingMobyTransport()
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport, clock: TestMobyClock())
        let games = try await client.games(ids: (1...6).map { GameID(rawValue: $0) }, maximumConcurrentRequests: 2)
        #expect(games.map(\.gameID) == Array(1...6))
        #expect(await transport.peak == 2)
    }

    @Test
    func emptyConsoleSelectionDoesNotFetchEveryGame() async throws {
        let transport = ScriptedMobyTransport([])
        let client = MobyAPIClient(credentials: TestCredentialStore(), transport: transport)
        let repository = MobyCatalogRepository(client: client)
        let page = try await repository.games(matching: CatalogQuery())
        #expect(page.games.isEmpty)
        #expect(page.nextOffset == nil)
        #expect(await transport.requests.isEmpty)
    }
}
