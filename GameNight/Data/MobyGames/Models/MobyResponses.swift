// SPDX-License-Identifier: GPL-3.0-or-later

/// Required envelope keys detect unexpected payloads. An explicit null list is empty;
/// a missing envelope key, incorrect element type, or missing identity is an error.
struct MobyGamesResponse<Game: Decodable & Sendable>: Decodable, Sendable {
    let games: [Game]

    private enum CodingKeys: String, CodingKey { case games }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        games = try container.decode([Game]?.self, forKey: .games) ?? []
    }
}

struct MobyPlatformsResponse: Decodable, Sendable {
    let platforms: [MobyPlatformDTO]

    private enum CodingKeys: String, CodingKey { case platforms }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        platforms = try container.decode([MobyPlatformDTO]?.self, forKey: .platforms) ?? []
    }
}

struct MobyGenresResponse: Decodable, Sendable {
    let genres: [MobyGenreDTO]

    private enum CodingKeys: String, CodingKey { case genres }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        genres = try container.decode([MobyGenreDTO]?.self, forKey: .genres) ?? []
    }
}

struct MobyGroupsResponse: Decodable, Sendable {
    let groups: [MobyGroupDTO]

    private enum CodingKeys: String, CodingKey { case groups }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groups = try container.decode([MobyGroupDTO]?.self, forKey: .groups) ?? []
    }
}

struct MobyScreenshotsResponse: Decodable, Sendable {
    let screenshots: [MobyImageDTO]

    private enum CodingKeys: String, CodingKey { case screenshots }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenshots = try container.decode([MobyImageDTO]?.self, forKey: .screenshots) ?? []
    }
}

struct MobyCoversResponse: Decodable, Sendable {
    let coverGroups: [MobyCoverGroupDTO]

    private enum CodingKeys: String, CodingKey { case coverGroups = "cover_groups" }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coverGroups = try container.decode([MobyCoverGroupDTO]?.self, forKey: .coverGroups) ?? []
    }
}
