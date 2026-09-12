// SPDX-License-Identifier: GPL-3.0-or-later

/// Release dates retain the API's precision: YYYY, YYYY-MM, or YYYY-MM-DD.
struct MobyPlatformDTO: Decodable, Sendable {
    let platformID: Int
    let platformName: String
    let firstReleaseDate: String?

    enum CodingKeys: String, CodingKey {
        case platformID = "platform_id"
        case platformName = "platform_name"
        case firstReleaseDate = "first_release_date"
    }
}

struct MobyPlatformDetailsDTO: Decodable, Sendable {
    let gameID: Int
    let platformID: Int
    let platformName: String
    let firstReleaseDate: String?
    let attributes: [MobyAttributeDTO]?
    let releases: [MobyReleaseDTO]?

    enum CodingKeys: String, CodingKey {
        case gameID = "game_id"
        case platformID = "platform_id"
        case platformName = "platform_name"
        case firstReleaseDate = "first_release_date"
        case attributes, releases
    }
}

struct MobyAttributeDTO: Decodable, Sendable {
    let attributeID: Int
    let attributeName: String
    let attributeCategoryID: Int?
    let attributeCategoryName: String?

    enum CodingKeys: String, CodingKey {
        case attributeID = "attribute_id"
        case attributeName = "attribute_name"
        case attributeCategoryID = "attribute_category_id"
        case attributeCategoryName = "attribute_category_name"
    }
}

struct MobyReleaseDTO: Decodable, Sendable {
    let releaseDate: String?
    let description: String?
    let countries: [String]?
    let companies: [MobyCompanyDTO]?

    enum CodingKeys: String, CodingKey {
        case releaseDate = "release_date"
        case description, countries, companies
    }
}

struct MobyCompanyDTO: Decodable, Sendable {
    let companyID: Int
    let companyName: String
    let role: String?

    enum CodingKeys: String, CodingKey {
        case companyID = "company_id"
        case companyName = "company_name"
        case role
    }
}
