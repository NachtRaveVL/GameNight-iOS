// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

/// Safe errors never carry file paths, personal records, or secret values.
enum LibraryStorageError: Error, Equatable, Sendable, LocalizedError {
    case unavailable
    case invalidData
    case unsupportedVersion(Int)
    case tooLarge

    var errorDescription: String? {
        switch self {
        case .unavailable: String(localized: "Your library could not be accessed. Please try again when the device is unlocked.")
        case .invalidData: String(localized: "Your library could not be read safely. Its existing contents have been preserved.")
        case .unsupportedVersion: String(localized: "This library uses an unsupported format. Its contents have been preserved.")
        case .tooLarge: String(localized: "The library exceeds the supported file size. Its existing contents have been preserved.")
        }
    }
}

enum CredentialStoreError: Error, Equatable, Sendable, LocalizedError {
    case invalidKey
    case deviceLocked
    case invalidData
    case unavailable

    var errorDescription: String? {
        switch self {
        case .invalidKey: String(localized: "Enter a valid API key without line breaks or control characters.")
        case .deviceLocked: String(localized: "Unlock your device to access the saved API key.")
        case .invalidData: String(localized: "The saved API key could not be read. You can replace it with a new key.")
        case .unavailable: String(localized: "Secure API-key storage is unavailable. Please try again.")
        }
    }
}
