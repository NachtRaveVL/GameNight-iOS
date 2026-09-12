// SPDX-License-Identifier: GPL-3.0-or-later

import Observation

/// Shared presentation settings; no persistence or activity tracking in this milestone.
@MainActor
@Observable
final class ThemeState {
    var preferences: ThemePreferences

    init(preferences: ThemePreferences = ThemePreferences()) {
        self.preferences = preferences
    }
}
