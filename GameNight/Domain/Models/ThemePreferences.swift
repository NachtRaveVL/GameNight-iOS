// SPDX-License-Identifier: GPL-3.0-or-later

/// Appearance and palette are independent. Persistence/settings controls remain GN-053.
struct ThemePreferences: Codable, Equatable, Sendable {
    var appearance: AppAppearance = .system
    var palette: AppPalette = .violet
}

enum AppAppearance: String, Codable, CaseIterable, Sendable {
    case system
    case light
    case dark
}

/// Initial palette options; final visual values are subject to the redlines.
enum AppPalette: String, Codable, CaseIterable, Sendable {
    case violet
    case ocean
    case amber
    case monochrome
}
