// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Immutable, shareable client. Only the injected limiter owns mutable shared state.
/// Keep one client/limiter per credential source in the composition root.
struct MobyAPIClient: Sendable {
    private let credentials: any CredentialStore
    private let transport: any HTTPTransport
    private let limiter: MobyRateLimiter
    private let clock: any MobyRequestClock
    private let retryPolicy: MobyRetryPolicy

    init(
        credentials: any CredentialStore,
        transport: any HTTPTransport = URLSessionHTTPTransport(),
        tier: MobyAccessTier = .nonCommercial,
        retryPolicy: MobyRetryPolicy = .limited,
        clock: any MobyRequestClock = ContinuousMobyClock()
    ) {
        self.credentials = credentials
        self.transport = transport
        self.clock = clock
        self.retryPolicy = retryPolicy
        limiter = MobyRateLimiter(tier: tier, clock: clock)
    }

    /// Swift 6.2+ explicitly runs orchestration and decoding on the concurrent
    /// executor, even when a main-actor view model awaits this method.
    @concurrent
    func send<Response: Decodable & Sendable>(_ request: MobyRequest<Response>) async throws -> Response {
        for attempt in 1...retryPolicy.maximumAttempts {
            try Task.checkCancellation()
            // Resolve credentials and build before admission, so Keychain latency
            // cannot bunch several previously admitted requests together.
            // A fresh key is read for each attempt; it is not cached by this client.
            let authorized = try request.urlRequest(apiKey: try await apiKey())
            try await limiter.waitForPermit()
            try Task.checkCancellation()

            let response: HTTPResponse
            do {
                response = try await transport.send(authorized)
            } catch {
                try Task.checkCancellation()
                if error is CancellationError { throw CancellationError() }
                if let urlError = error as? URLError {
                    if urlError.code == .cancelled { throw CancellationError() }
                    if [.timedOut, .networkConnectionLost].contains(urlError.code),
                       attempt < retryPolicy.maximumAttempts {
                        try await clock.sleep(for: retryPolicy.backoff(after: attempt))
                        continue
                    }
                    throw MobyAPIError.transport(code: urlError.errorCode)
                }
                if let apiError = error as? MobyAPIError { throw apiError }
                throw MobyAPIError.transport(code: URLError.unknown.rawValue)
            }

            try Task.checkCancellation()
            if (200..<300).contains(response.statusCode) {
                do {
                    // Decoder instances are request-local, never concurrently shared.
                    let result = try JSONDecoder().decode(Response.self, from: response.data)
                    try Task.checkCancellation()
                    return result
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    throw MobyAPIError.decodingFailed
                }
            }

            if response.statusCode == 429 {
                let delay = MobyRetryAfter.seconds(from: response.retryAfter) ?? 30
                await limiter.deferRequests(for: delay)
                if attempt < retryPolicy.maximumAttempts, delay <= retryPolicy.maximumAutomaticDelay {
                    continue
                }
                throw MobyAPIError.rateLimited(retryAfter: delay)
            }

            if [502, 503, 504].contains(response.statusCode) {
                let delay = MobyRetryAfter.seconds(from: response.retryAfter)
                    ?? retryPolicy.backoff(after: attempt)
                // Share the cooldown even if this caller will not retry.
                await limiter.deferRequests(for: delay)
                if attempt < retryPolicy.maximumAttempts, delay <= retryPolicy.maximumAutomaticDelay {
                    continue
                }
            }

            switch response.statusCode {
            case 401: throw MobyAPIError.unauthorized
            case 404: throw MobyAPIError.notFound
            default: throw MobyAPIError.httpStatus(response.statusCode)
            }
        }
        throw MobyAPIError.invalidResponse
    }

    /// Bounded structured concurrency; result order matches the input order.
    /// A failure/cancellation cancels sibling tasks and propagates to the caller.
    @concurrent
    func games(ids: [GameID], maximumConcurrentRequests: Int = 4) async throws -> [MobyGameDTO] {
        guard (1...8).contains(maximumConcurrentRequests) else {
            throw MobyAPIError.invalidRequest(.invalidConcurrency)
        }
        let requests = try ids.map { try MobyRequests.game($0) }
        try Task.checkCancellation()
        return try await withThrowingTaskGroup(of: (Int, MobyGameDTO).self) { group in
            var next = 0
            var results = [MobyGameDTO?](repeating: nil, count: requests.count)
            while next < min(maximumConcurrentRequests, requests.count) {
                let index = next
                group.addTask { (index, try await send(requests[index])) }
                next += 1
            }
            for try await (index, game) in group {
                try Task.checkCancellation()
                results[index] = game
                if next < requests.count {
                    let index = next
                    group.addTask { (index, try await send(requests[index])) }
                    next += 1
                }
            }
            return try results.map { result in
                guard let result else { throw MobyAPIError.invalidResponse }
                return result
            }
        }
    }

    /// Independent media endpoints overlap when the shared request quota permits.
    @concurrent
    func artwork(for releaseID: GameReleaseID) async throws -> MobyReleaseArtworkDTO {
        let covers = try MobyRequests.covers(for: releaseID)
        let screenshots = try MobyRequests.screenshots(for: releaseID)
        async let coverResponse = send(covers)
        async let screenshotResponse = send(screenshots)
        let (coverResult, screenshotResult) = try await (coverResponse, screenshotResponse)
        return MobyReleaseArtworkDTO(
            releaseID: releaseID,
            coverGroups: coverResult.coverGroups,
            screenshots: screenshotResult.screenshots
        )
    }

    private func apiKey() async throws -> String {
        let key: String?
        do {
            key = try await credentials.mobyGamesAPIKey()
        } catch {
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            throw MobyAPIError.credentialStoreUnavailable
        }
        try Task.checkCancellation()
        guard let key, !key.isEmpty, !key.allSatisfy(\.isWhitespace) else { throw MobyAPIError.missingAPIKey }
        return key
    }
}
