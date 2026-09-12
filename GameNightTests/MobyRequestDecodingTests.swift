// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Testing
@testable import GameNight

struct MobyRequestDecodingTests {
    @Test
    func queryValuesRoundTripWithoutChangingTheSecret() throws {
        let key = "synthetic+A/B=C&D% ?#"
        let title = "Example + café & mystery"
        let filter = MobyGameFilter(
            title: title,
            platformIDs: [PlatformID(rawValue: 2), PlatformID(rawValue: 3)],
            genreIDs: [4, 5]
        )
        let request = try MobyRequests.games(matching: filter).urlRequest(apiKey: key)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = try #require(components.queryItems)

        #expect(url.scheme == "https")
        #expect(url.host == "api.mobygames.com")
        #expect(url.path == "/v1/games")
        #expect(query.first { $0.name == "api_key" }?.value == key)
        #expect(query.first { $0.name == "title" }?.value == title)
        #expect(query.filter { $0.name == "platform" }.compactMap(\.value) == ["2", "3"])
        #expect(query.filter { $0.name == "genre" }.compactMap(\.value) == ["4", "5"])
        #expect(components.percentEncodedQuery?.contains("%2B") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test
    func invalidParametersFailBeforeNetworkConstruction() {
        #expect(throws: MobyAPIError.invalidRequest(.invalidPagination)) {
            _ = try MobyRequests.games(page: MobyPage(limit: 101))
        }
        #expect(throws: MobyAPIError.invalidRequest(.invalidPagination)) {
            _ = try MobyRequests.games(page: MobyPage(offset: -1))
        }
        #expect(throws: MobyAPIError.invalidRequest(.invalidIdentifier)) {
            _ = try MobyRequests.game(GameID(rawValue: 0))
        }
        #expect(throws: MobyAPIError.invalidRequest(.titleTooLong)) {
            _ = try MobyRequests.games(matching: MobyGameFilter(title: String(repeating: "a", count: 129)))
        }
        #expect(throws: MobyAPIError.invalidRequest(.invalidAge)) {
            _ = try MobyRequests.recentGameIDs(age: 22)
        }
    }

    @Test
    func platformSpecificEndpointsPreserveBothIdentities() throws {
        let release = GameReleaseID(gameID: GameID(rawValue: 42), platformID: PlatformID(rawValue: 7))
        let covers = try MobyRequests.covers(for: release).urlRequest(apiKey: "synthetic")
        let screenshots = try MobyRequests.screenshots(for: release).urlRequest(apiKey: "synthetic")

        #expect(covers.url?.path == "/v1/games/42/platforms/7/covers")
        #expect(screenshots.url?.path == "/v1/games/42/platforms/7/screenshots")
    }

    @Test
    func formatsHaveMatchingResponseShapes() throws {
        let decoder = JSONDecoder()
        let ids = try decoder.decode(MobyGamesResponse<Int>.self, from: Data(#"{"games":[1,2]}"#.utf8))
        let brief = try decoder.decode(
            MobyGamesResponse<MobyGameSummaryDTO>.self,
            from: Data(#"{"games":[{"game_id":1,"title":"Example"}]}"#.utf8)
        )
        let single = try decoder.decode(MobyGameDTO.self, from: Data(#"{"game_id":1,"title":"Example"}"#.utf8))

        #expect(ids.games == [1, 2])
        #expect(brief.games.first?.gameID == 1)
        #expect(single.title == "Example")
    }

    @Test
    func optionalMetadataDoesNotInventDatesOrLoseClassification() throws {
        let data = Data(#"""
        {
          "games": [{
            "game_id": 42, "title": "Example", "description": "<p>A mystery.</p>",
            "moby_score": 3.8, "num_votes": 12, "official_url": null,
            "sample_cover": null, "sample_screenshots": [],
            "genres": [{"genre_id": 55, "genre_name": "Detective / Mystery", "genre_category": "Narrative"}],
            "platforms": [
              {"platform_id": 7, "platform_name": "Example console", "first_release_date": "1998"},
              {"platform_id": 8, "platform_name": "Other console", "first_release_date": "1999-06"}
            ],
            "future_field": {"ignored": true}
          }]
        }
        """#.utf8)
        let response = try JSONDecoder().decode(MobyGamesResponse<MobyGameDTO>.self, from: data)
        let game = try #require(response.games.first)

        #expect(game.description == "<p>A mystery.</p>")
        #expect(game.mobyScore == 3.8)
        #expect(game.platforms?.map(\.firstReleaseDate) == ["1998", "1999-06"])
        #expect(game.genres?.first?.genreCategory == "Narrative")
        #expect(game.sampleCover == nil)
        #expect(game.sampleScreenshots?.isEmpty == true)
    }

    @Test
    func nullListsAreAcceptedButMissingEnvelopesAndInvalidIdentitiesAreNot() throws {
        let decoder = JSONDecoder()
        let empty = try decoder.decode(MobyGamesResponse<MobyGameDTO>.self, from: Data(#"{"games":null}"#.utf8))
        #expect(empty.games.isEmpty)
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(MobyGamesResponse<MobyGameDTO>.self, from: Data(#"{}"#.utf8))
        }
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(
                MobyGamesResponse<MobyGameDTO>.self,
                from: Data(#"{"games":[{"title":"Missing identity"}]}"#.utf8)
            )
        }
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(
                MobyGamesResponse<MobyGameDTO>.self,
                from: Data(#"{"games":[{"game_id":"wrong type","title":"Example"}]}"#.utf8)
            )
        }
    }

    @Test
    func releaseAndMediaResponsesDecodeWithoutAssumingUnknownFields() throws {
        let decoder = JSONDecoder()
        let details = try decoder.decode(MobyPlatformDetailsDTO.self, from: Data(#"""
        {"game_id":42,"platform_id":7,"platform_name":"Example","first_release_date":"1995",
         "attributes":[{"attribute_id":489,"attribute_name":"1 Player","attribute_category_id":40}],
         "releases":[{"countries":["United States"],"release_date":"1995-06-12",
         "companies":[{"company_id":3,"company_name":"Example Studio","role":"Published by"}]}],
         "ratings":[],"patches":[]}
        """#.utf8))
        let covers = try decoder.decode(MobyCoversResponse.self, from: Data(#"""
        {"cover_groups":[{"comments":null,"countries":["Germany"],"covers":[
         {"scan_of":"Front Cover","image":"https://www.mobygames.com/example.png","width":800,"height":1000}
        ]}]}
        """#.utf8))
        let shots = try decoder.decode(MobyScreenshotsResponse.self, from: Data(#"""
        {"screenshots":[{"image":null,"caption":"Opening screen","width":640,"height":480}]}
        """#.utf8))
        #expect(details.releases?.first?.companies?.first?.role == "Published by")
        #expect(details.releases?.first?.releaseDate == "1995-06-12")
        #expect(covers.coverGroups.first?.covers?.first?.scanOf == "Front Cover")
        #expect(covers.coverGroups.first?.countries == ["Germany"])
        #expect(shots.screenshots.first?.image == nil)
    }

    @Test
    func retryAfterHandlesSecondsHTTPDatesAndInvalidHeaders() {
        let now = Date(timeIntervalSince1970: 0)
        #expect(MobyRetryAfter.seconds(from: "12", now: now) == 12)
        #expect(MobyRetryAfter.seconds(from: "Thu, 01 Jan 1970 00:01:00 GMT", now: now) == 60)
        #expect(MobyRetryAfter.seconds(from: "Thu, 01 Jan 1970 00:00:00 GMT", now: now) == 0)
        #expect(MobyRetryAfter.seconds(from: "-1", now: now) == nil)
        #expect(MobyRetryAfter.seconds(from: "nonsense", now: now) == nil)
    }
}
