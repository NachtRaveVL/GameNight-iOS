// SPDX-License-Identifier: GPL-3.0-or-later

struct MobyImageDTO: Decodable, Sendable {
    let image: String?
    let thumbnailImage: String?
    let width: Int?
    let height: Int?
    let caption: String?

    enum CodingKeys: String, CodingKey {
        case image, width, height, caption
        case thumbnailImage = "thumbnail_image"
    }
}

/// A generic sample cover can refer to a different console than the selected one.
struct MobySampleCoverDTO: Decodable, Sendable {
    let image: String?
    let thumbnailImage: String?
    let width: Int?
    let height: Int?
    let platforms: [String]?

    enum CodingKeys: String, CodingKey {
        case image, width, height, platforms
        case thumbnailImage = "thumbnail_image"
    }
}

struct MobyCoverGroupDTO: Decodable, Sendable {
    let comments: String?
    let countries: [String]?
    let covers: [MobyCoverDTO]?
}

struct MobyCoverDTO: Decodable, Sendable {
    let image: String?
    let thumbnailImage: String?
    let width: Int?
    let height: Int?
    let scanOf: String?
    let description: String?
    let comments: String?

    enum CodingKeys: String, CodingKey {
        case image, width, height, description, comments
        case thumbnailImage = "thumbnail_image"
        case scanOf = "scan_of"
    }
}

/// The game/platform context is supplied by the request, not inferred from image names.
struct MobyReleaseArtworkDTO: Sendable {
    let releaseID: GameReleaseID
    let coverGroups: [MobyCoverGroupDTO]
    let screenshots: [MobyImageDTO]
}
