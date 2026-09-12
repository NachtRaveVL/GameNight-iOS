// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

/// Provider data stays in the data layer. Descriptions may contain HTML.
struct MobyGameDTO: Decodable, Sendable {
    let gameID: Int
    let title: String
    let description: String?
    let alternateTitles: [MobyAlternateTitleDTO]?
    let genres: [MobyGenreDTO]?
    let platforms: [MobyPlatformDTO]?
    let mobyScore: Double?
    let numVotes: Int?
    let mobyURL: String?
    let officialURL: String?
    let sampleCover: MobySampleCoverDTO?
    let sampleScreenshots: [MobyImageDTO]?

    enum CodingKeys: String, CodingKey {
        case gameID = "game_id"
        case title, description, genres, platforms
        case alternateTitles = "alternate_titles"
        case mobyScore = "moby_score"
        case numVotes = "num_votes"
        case mobyURL = "moby_url"
        case officialURL = "official_url"
        case sampleCover = "sample_cover"
        case sampleScreenshots = "sample_screenshots"
    }
}

struct MobyGameSummaryDTO: Decodable, Sendable {
    let gameID: Int
    let title: String
    let mobyURL: String?

    enum CodingKeys: String, CodingKey {
        case gameID = "game_id"
        case title
        case mobyURL = "moby_url"
    }
}

struct MobyAlternateTitleDTO: Decodable, Sendable {
    let title: String
    let description: String?
}

struct MobyGenreDTO: Decodable, Sendable {
    let genreID: Int
    let genreName: String
    let genreCategoryID: Int?
    let genreCategory: String?
    let genreDescription: String?

    enum CodingKeys: String, CodingKey {
        case genreID = "genre_id"
        case genreName = "genre_name"
        case genreCategoryID = "genre_category_id"
        case genreCategory = "genre_category"
        case genreDescription = "genre_description"
    }
}

struct MobyGroupDTO: Decodable, Sendable {
    let groupID: Int
    let groupName: String
    let groupDescription: String?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case groupDescription = "group_description"
    }
}
