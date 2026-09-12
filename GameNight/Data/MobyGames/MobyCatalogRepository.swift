// SPDX-License-Identifier: GPL-3.0-or-later

/// Maps provider records into the existing UI-independent catalog contract.
struct MobyCatalogRepository: CatalogRepository {
    let client: MobyAPIClient

    @concurrent
    func platforms() async throws -> [GamePlatform] {
        let response = try await client.send(MobyRequests.platforms())
        return try response.platforms.map { platform in
            guard platform.platformID > 0 else { throw MobyAPIError.invalidResponse }
            return GamePlatform(id: PlatformID(rawValue: platform.platformID), name: platform.platformName)
        }
    }

    @concurrent
    func games(matching query: CatalogQuery) async throws -> CatalogPage {
        var filter = MobyGameFilter(title: query.title.isEmpty ? nil : query.title)
        switch query.scope {
        case .myConsoles(let platforms):
            // An empty personal selection must not trigger an unfiltered catalog request.
            guard !platforms.isEmpty else { return CatalogPage(games: [], nextOffset: nil) }
            filter.platformIDs = platforms
        case .allConsoles:
            break
        }
        let page = MobyPage(offset: query.offset)
        let response = try await client.send(MobyRequests.games(matching: filter, page: page))
        let games = try response.games.map { game in
            let platforms = game.platforms ?? []
            guard game.gameID > 0, platforms.allSatisfy({ $0.platformID > 0 }) else {
                throw MobyAPIError.invalidResponse
            }
            return CatalogGame(
                id: GameID(rawValue: game.gameID),
                title: game.title,
                platformIDs: platforms.map { PlatformID(rawValue: $0.platformID) }
            )
        }
        // The API supplies no total. A full page permits a next-page probe, not a guarantee of more results.
        let nextOffset = response.games.count == page.limit ? page.offset + page.limit : nil
        return CatalogPage(games: games, nextOffset: nextOffset)
    }
}
