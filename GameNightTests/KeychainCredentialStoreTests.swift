// SPDX-License-Identifier: GPL-3.0-or-later

#if canImport(Security)
import Foundation
import Security
import Testing
@testable import GameNight

struct KeychainCredentialStoreTests {
    @Test
    func roundTripReplacementDeletionAndDeviceOnlyAttributes() async throws {
        let service = "org.nrretroworks.gamenight.tests.\(UUID().uuidString)"
        let store = KeychainCredentialStore(service: service)
        do {
            #expect(try await store.mobyGamesAPIKey() == nil)
            try await store.setMobyGamesAPIKey("synthetic+first")
            try await store.setMobyGamesAPIKey("synthetic+replacement")
            #expect(try await store.mobyGamesAPIKey() == "synthetic+replacement")
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: "api-key",
                kSecAttrSynchronizable as String: false,
                kSecReturnAttributes as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            #expect(status == errSecSuccess)
            let attributes = try #require(item as? [String: Any])
            #expect(attributes[kSecAttrAccessible as String] as? String == kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String)
            #expect((attributes[kSecAttrSynchronizable as String] as? NSNumber)?.boolValue != true)
            try await store.deleteMobyGamesAPIKey()
            try await store.deleteMobyGamesAPIKey()
            #expect(try await store.mobyGamesAPIKey() == nil)
        } catch {
            try await store.deleteMobyGamesAPIKey()
            throw error
        }
    }
}
#endif
