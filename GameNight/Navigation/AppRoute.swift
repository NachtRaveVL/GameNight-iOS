// SPDX-License-Identifier: GPL-3.0-or-later

/// Nil identities are reserved for scaffold previews, never fabricated catalog data.
enum AppRoute: Hashable, Sendable {
    case consoleCatalog(PlatformID?)
    case gameDetail(GameReleaseID?)
    case recommendationTuning(GameID?)
    case tonight
    case shelves
    case resumeNote(GameReleaseID?)
    case gameNight
    case consoleSelection
    case tasteSetup
    case apiKey
    case artworkSources
    case dataTransfer
    case hiddenGames
}

enum AppSheet: Hashable, Identifiable, Sendable {
    case onboarding
    case artwork(GameReleaseID?)

    var id: Self { self }
}

enum NavigationIntent: Sendable {
    case push(AppRoute)
    case present(AppSheet)
    case dismissSheet
}
