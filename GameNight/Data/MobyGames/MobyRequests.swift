// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct MobyPage: Sendable {
    var limit = 100
    var offset = 0
}

/// ID lookups are a separate endpoint factory because the API ignores other
/// filters when `id` is present. Repeated parameters are preserved in order.
struct MobyGameFilter: Sendable {
    var title: String?
    var platformIDs: [PlatformID] = []
    var genreIDs: [Int] = []
    var groupIDs: [Int] = []
}

struct MobyRequest<Response: Decodable & Sendable>: Sendable {
    fileprivate let path: String
    fileprivate let parameters: [(String, String)]

    /// The only request origin is fixed here; credentials cannot be sent to an
    /// endpoint-supplied host. The request itself never stores the API key.
    func urlRequest(apiKey: String) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mobygames.com"
        components.path = "/v1/" + path
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        components.percentEncodedQuery = try (parameters + [("api_key", apiKey)]).map { name, value in
            guard let name = name.addingPercentEncoding(withAllowedCharacters: allowed),
                  let value = value.addingPercentEncoding(withAllowedCharacters: allowed) else {
                throw MobyAPIError.invalidResponse
            }
            return name + "=" + value
        }.joined(separator: "&")
        guard let url = components.url else { throw MobyAPIError.invalidResponse }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

/// Each factory fixes the expected response type and validates documented bounds.
enum MobyRequests {
    static func platforms() -> MobyRequest<MobyPlatformsResponse> {
        MobyRequest(path: "platforms", parameters: [])
    }

    static func genres() -> MobyRequest<MobyGenresResponse> {
        MobyRequest(path: "genres", parameters: [])
    }

    static func groups(page: MobyPage = MobyPage()) throws -> MobyRequest<MobyGroupsResponse> {
        MobyRequest(path: "groups", parameters: try pagination(page))
    }

    static func games(
        matching filter: MobyGameFilter = MobyGameFilter(),
        page: MobyPage = MobyPage()
    ) throws -> MobyRequest<MobyGamesResponse<MobyGameDTO>> {
        MobyRequest(path: "games", parameters: try parameters(filter, page: page) + [("format", "normal")])
    }

    static func gameSummaries(
        matching filter: MobyGameFilter = MobyGameFilter(),
        page: MobyPage = MobyPage()
    ) throws -> MobyRequest<MobyGamesResponse<MobyGameSummaryDTO>> {
        MobyRequest(path: "games", parameters: try parameters(filter, page: page) + [("format", "brief")])
    }

    static func gameIDs(
        matching filter: MobyGameFilter = MobyGameFilter(),
        page: MobyPage = MobyPage()
    ) throws -> MobyRequest<MobyGamesResponse<Int>> {
        MobyRequest(path: "games", parameters: try parameters(filter, page: page) + [("format", "id")])
    }

    static func game(_ id: GameID) throws -> MobyRequest<MobyGameDTO> {
        try validateIDs([id.rawValue])
        return MobyRequest(path: "games/\(id.rawValue)", parameters: [("format", "normal")])
    }

    static func gameSummary(_ id: GameID) throws -> MobyRequest<MobyGameSummaryDTO> {
        try validateIDs([id.rawValue])
        return MobyRequest(path: "games/\(id.rawValue)", parameters: [("format", "brief")])
    }

    static func platforms(for gameID: GameID) throws -> MobyRequest<MobyPlatformsResponse> {
        try validateIDs([gameID.rawValue])
        return MobyRequest(path: "games/\(gameID.rawValue)/platforms", parameters: [])
    }

    static func platformDetails(for releaseID: GameReleaseID) throws -> MobyRequest<MobyPlatformDetailsDTO> {
        MobyRequest(path: try releasePath(releaseID), parameters: [])
    }

    static func screenshots(for releaseID: GameReleaseID) throws -> MobyRequest<MobyScreenshotsResponse> {
        MobyRequest(path: try releasePath(releaseID) + "/screenshots", parameters: [])
    }

    static func covers(for releaseID: GameReleaseID) throws -> MobyRequest<MobyCoversResponse> {
        MobyRequest(path: try releasePath(releaseID) + "/covers", parameters: [])
    }

    /// Recently edited catalog records, not newly released games.
    static func recentGameIDs(age: Int = 21, page: MobyPage = MobyPage()) throws
        -> MobyRequest<MobyGamesResponse<Int>> {
        guard (1...21).contains(age) else { throw MobyAPIError.invalidRequest(.invalidAge) }
        return MobyRequest(
            path: "games/recent",
            parameters: try pagination(page) + [("age", String(age)), ("format", "id")]
        )
    }

    /// No platform filter is documented. Results refresh at most once per five minutes.
    static func randomGameIDs(limit: Int = 100) throws -> MobyRequest<MobyGamesResponse<Int>> {
        guard (1...100).contains(limit) else { throw MobyAPIError.invalidRequest(.invalidPagination) }
        return MobyRequest(path: "games/random", parameters: [("limit", String(limit)), ("format", "id")])
    }

    private static func parameters(_ filter: MobyGameFilter, page: MobyPage) throws -> [(String, String)] {
        var result = try pagination(page)
        if let title = filter.title {
            guard title.unicodeScalars.count <= 128 else { throw MobyAPIError.invalidRequest(.titleTooLong) }
            result.append(("title", title))
        }
        let platforms = filter.platformIDs.map(\.rawValue)
        try validateIDs(platforms + filter.genreIDs + filter.groupIDs)
        result += platforms.map { ("platform", String($0)) }
        result += filter.genreIDs.map { ("genre", String($0)) }
        result += filter.groupIDs.map { ("group", String($0)) }
        return result
    }

    private static func pagination(_ page: MobyPage) throws -> [(String, String)] {
        guard (1...100).contains(page.limit), page.offset >= 0,
              page.offset <= Int.max - page.limit else {
            throw MobyAPIError.invalidRequest(.invalidPagination)
        }
        return [("limit", String(page.limit)), ("offset", String(page.offset))]
    }

    private static func releasePath(_ releaseID: GameReleaseID) throws -> String {
        try validateIDs([releaseID.gameID.rawValue, releaseID.platformID.rawValue])
        return "games/\(releaseID.gameID.rawValue)/platforms/\(releaseID.platformID.rawValue)"
    }

    private static func validateIDs(_ ids: [Int]) throws {
        guard ids.allSatisfy({ $0 > 0 }) else { throw MobyAPIError.invalidRequest(.invalidIdentifier) }
    }
}
