// SPDX-License-Identifier: GPL-3.0-or-later

/// A MobyGames game identity, independent of platform or artwork source.
struct GameID: RawRepresentable, Codable, Hashable, Sendable {
    let rawValue: Int
}

/// A MobyGames platform identity; display names must never be used as keys.
struct PlatformID: RawRepresentable, Codable, Hashable, Sendable {
    let rawValue: Int
}

/// The unit of personal progress: one game on one platform.
struct GameReleaseID: Codable, Hashable, Sendable {
    let gameID: GameID
    let platformID: PlatformID
}
