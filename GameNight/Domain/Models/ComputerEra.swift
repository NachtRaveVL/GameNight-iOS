// SPDX-License-Identifier: GPL-3.0-or-later

/// Editorial collections, not operating-system compatibility guarantees or year filters.
/// Mac/Linux boundaries remain provisional until curated release mappings are available.
enum ComputerEra: String, Codable, CaseIterable, Sendable {
    case dos
    case windows3x
    case windows9x
    case windows2000XPVista
    case windows7And8
    case windows10And11
    case classicMacintosh
    case macOSPowerPC
    case macOSIntel
    case macOSAppleSilicon
    case earlyLinux
    case desktopLinux
    case steamEraLinux

    enum Family: String, Codable, CaseIterable, Sendable {
        case windows
        case mac
        case linux
    }

    var family: Family {
        switch self {
        case .dos, .windows3x, .windows9x, .windows2000XPVista, .windows7And8, .windows10And11: .windows
        case .classicMacintosh, .macOSPowerPC, .macOSIntel, .macOSAppleSilicon: .mac
        case .earlyLinux, .desktopLinux, .steamEraLinux: .linux
        }
    }
}

/// One actual provider release can belong to multiple curated eras.
/// An absent mapping means unknown, never an invitation to guess from its release year.
struct ComputerEraAssignment: Equatable, Sendable {
    let releaseID: GameReleaseID
    let eras: Set<ComputerEra>
}

/// Browsing collections remain separate from MobyGames platform IDs and API query filters.
enum CatalogCollection: Hashable, Sendable {
    case platform(PlatformID)
    case computerEra(ComputerEra)
}
