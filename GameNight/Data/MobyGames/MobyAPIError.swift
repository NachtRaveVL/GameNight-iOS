// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

enum MobyRequestIssue: Equatable, Sendable {
    case invalidIdentifier
    case invalidPagination
    case titleTooLong
    case invalidAge
    case invalidConcurrency
}

/// Only sanitized values cross the client boundary. Never attach a URL, key,
/// provider response body, raw NSError, or DecodingError to a user-visible error.
enum MobyAPIError: Error, Equatable, Sendable {
    case missingAPIKey
    case credentialStoreUnavailable
    case invalidRequest(MobyRequestIssue)
    case unauthorized
    case notFound
    case rateLimited(retryAfter: TimeInterval)
    case httpStatus(Int)
    case invalidResponse
    case decodingFailed
    case transport(code: Int)
}

extension MobyAPIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            String(localized: "A MobyGames API key is required.")
        case .credentialStoreUnavailable:
            String(localized: "Secure API-key storage is not available yet.")
        case .invalidRequest:
            String(localized: "The MobyGames request contains an invalid parameter.")
        case .unauthorized:
            String(localized: "MobyGames did not accept the API key.")
        case .notFound:
            String(localized: "The requested MobyGames entry was not found.")
        case .rateLimited:
            String(localized: "MobyGames is limiting requests. Please try again later.")
        case .httpStatus:
            String(localized: "MobyGames could not complete the request.")
        case .invalidResponse, .decodingFailed:
            String(localized: "MobyGames returned an unexpected response.")
        case .transport:
            String(localized: "The connection to MobyGames could not be completed.")
        }
    }
}
