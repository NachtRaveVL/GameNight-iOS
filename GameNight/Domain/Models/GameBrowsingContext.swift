// SPDX-License-Identifier: GPL-3.0-or-later

/// Temporary navigation context. This ordering belongs to results, not the user's shortlist.
struct GameBrowsingContext: Hashable, Sendable {
    let releases: [GameReleaseID]
    private(set) var selectedIndex: Int

    init?(releases: [GameReleaseID], selectedIndex: Int = 0) {
        guard releases.indices.contains(selectedIndex) else { return nil }
        self.releases = releases
        self.selectedIndex = selectedIndex
    }

    var releaseID: GameReleaseID { releases[selectedIndex] }
    var hasPrevious: Bool { selectedIndex > 0 }
    var hasNext: Bool { selectedIndex < releases.count - 1 }

    @discardableResult
    mutating func moveNext() -> Bool {
        guard hasNext else { return false }
        selectedIndex += 1
        return true
    }

    @discardableResult
    mutating func movePrevious() -> Bool {
        guard hasPrevious else { return false }
        selectedIndex -= 1
        return true
    }
}
