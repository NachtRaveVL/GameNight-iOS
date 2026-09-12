// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

/// Only surrounding paste whitespace is removed; punctuation (including '+') is preserved.
enum MobyAPIKey {
    static func normalized(_ value: String) throws -> String {
        let key = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // A local input bound, not a claim about MobyGames' key format.
        guard !key.isEmpty, key.utf8.count <= 4096,
              !key.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) else {
            throw CredentialStoreError.invalidKey
        }
        return key
    }
}
