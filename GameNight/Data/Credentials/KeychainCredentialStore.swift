// SPDX-License-Identifier: GPL-3.0-or-later

#if canImport(Security)
import Foundation
import Security

/// Synchronous Security calls are isolated to this actor, never the UI actor.
/// One private, non-synchronizing item, accessible only while this device is unlocked.
actor KeychainCredentialStore: CredentialStore {
    private let service: String
    private let account = "api-key"

    init(service: String = "org.nrretroworks.gamenight.mobygames") {
        self.service = service
    }

    func mobyGamesAPIKey() throws -> String? {
        try Task.checkCancellation()
        var query = identity
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUIFail
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        try check(status)
        guard let data = item as? Data, let key = String(data: data, encoding: .utf8), !key.isEmpty else {
            throw CredentialStoreError.invalidData
        }
        return key
    }

    func setMobyGamesAPIKey(_ value: String) throws {
        try Task.checkCancellation()
        let key = try MobyAPIKey.normalized(value)
        let attributes: [String: Any] = [
            kSecValueData as String: Data(key.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        var status = SecItemUpdate(identity as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let item = identity.merging(attributes) { _, new in new }
            status = SecItemAdd(item as CFDictionary, nil)
            if status == errSecDuplicateItem {
                status = SecItemUpdate(identity as CFDictionary, attributes as CFDictionary)
            }
        }
        // Never delete before replacing. A failed replacement must retain the previous key.
        // Do not report cancellation after a successful commit.
        try check(status)
    }

    func deleteMobyGamesAPIKey() throws {
        try Task.checkCancellation()
        let status = SecItemDelete(identity as CFDictionary)
        if status != errSecItemNotFound { try check(status) }
    }

    private var identity: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: false
        ]
    }

    private func check(_ status: OSStatus) throws {
        switch status {
        case errSecSuccess: return
        case errSecInteractionNotAllowed: throw CredentialStoreError.deviceLocked
        default: throw CredentialStoreError.unavailable
        }
    }
}
#endif
