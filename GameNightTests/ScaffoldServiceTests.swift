// SPDX-License-Identifier: GPL-3.0-or-later

import Testing
@testable import GameNight

struct ScaffoldServiceTests {
    @Test
    func unimplementedSaveCannotReportSuccess() async {
        let repository = ScaffoldPlayerLibraryRepository()

        await #expect(throws: ScaffoldError.notImplemented(.localStorage)) {
            try await repository.save(LibrarySnapshot())
        }
    }

    @Test
    func unimplementedCredentialStorageCannotAcceptAKey() async {
        let store = ScaffoldCredentialStore()

        await #expect(throws: ScaffoldError.notImplemented(.credentials)) {
            try await store.setMobyGamesAPIKey("synthetic-test-value")
        }
    }

    @Test
    func unimplementedCatalogCannotMasqueradeAsAnEmptyLibrary() async {
        let repository = ScaffoldCatalogRepository()

        await #expect(throws: ScaffoldError.notImplemented(.catalog)) {
            _ = try await repository.games(matching: CatalogQuery())
        }
    }
}
