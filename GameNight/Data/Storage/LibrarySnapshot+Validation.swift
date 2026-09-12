// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

extension LibrarySnapshot {
    /// Validate before accepting disk contents or publishing a replacement.
    func validateForStorage() throws {
        func valid(_ release: GameReleaseID) -> Bool {
            release.gameID.rawValue > 0 && release.platformID.rawValue > 0
        }
        guard selectedPlatformIDs.allSatisfy({ $0.rawValue > 0 }),
              Set(selectedPlatformIDs).count == selectedPlatformIDs.count,
              favoriteGameIDs.allSatisfy({ $0.rawValue > 0 }),
              Set(favoriteGameIDs).count == favoriteGameIDs.count,
              excludedGameIDs.allSatisfy({ $0.rawValue > 0 }),
              Set(records.map(\.id)).count == records.count,
              Set(shelves.map(\.id)).count == shelves.count,
              records.allSatisfy({ record in
                  valid(record.id) && (record.completion?.date?.timeIntervalSince1970.isFinite ?? true)
              }),
              shelves.allSatisfy({ $0.games.allSatisfy(valid) }) else {
            throw LibraryStorageError.invalidData
        }
    }
}
