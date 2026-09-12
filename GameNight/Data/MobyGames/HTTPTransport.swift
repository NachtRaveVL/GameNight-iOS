// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct HTTPResponse: Sendable {
    let statusCode: Int
    let data: Data
    var retryAfter: String?
}

protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> HTTPResponse
}

/// Reuses a connection pool, but persists no cookies, URL credentials, or responses.
/// URLSession suspends the calling task during I/O; it does not block the main thread.
final class URLSessionHTTPTransport: HTTPTransport {
    private let session: URLSession

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.urlCredentialStorage = nil
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration, delegate: RejectRedirectsDelegate(), delegateQueue: nil)
    }

    deinit {
        session.invalidateAndCancel()
    }

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw MobyAPIError.invalidResponse }
        return HTTPResponse(
            statusCode: response.statusCode,
            data: data,
            retryAfter: response.value(forHTTPHeaderField: "Retry-After")
        )
    }
}

/// A query-string credential must never follow a redirect, even to a related host.
final class RejectRedirectsDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
