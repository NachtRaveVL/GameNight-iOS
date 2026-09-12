// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

extension ComputerEra {
    var title: String {
        switch self {
        case .dos: String(localized: "DOS")
        case .windows3x: String(localized: "Windows 3.x / 3.11")
        case .windows9x: String(localized: "Windows 95/98/Me")
        case .windows2000XPVista: String(localized: "Windows 2000/XP/Vista")
        case .windows7And8: String(localized: "Windows 7/8")
        case .windows10And11: String(localized: "Windows 10/11")
        case .classicMacintosh: String(localized: "Classic Macintosh")
        case .macOSPowerPC: String(localized: "Mac OS X: PowerPC era")
        case .macOSIntel: String(localized: "Mac OS X/macOS: Intel era")
        case .macOSAppleSilicon: String(localized: "macOS: Apple silicon era")
        case .earlyLinux: String(localized: "Early Linux gaming")
        case .desktopLinux: String(localized: "Desktop Linux gaming")
        case .steamEraLinux: String(localized: "Steam-era Linux")
        }
    }
}
