// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI
import UIKit

/// Shared semantic roles. Native text/surfaces retain system contrast and appearance behavior.
enum AppTheme {
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let separator = Color(uiColor: .separator)

    static func accent(for palette: AppPalette) -> Color {
        let light: UIColor
        let dark: UIColor
        switch palette {
        case .violet:
            light = UIColor(red: 0.35, green: 0.22, blue: 0.70, alpha: 1)
            dark = UIColor(red: 0.77, green: 0.66, blue: 1, alpha: 1)
        case .ocean:
            light = UIColor(red: 0, green: 0.35, blue: 0.48, alpha: 1)
            dark = UIColor(red: 0.40, green: 0.84, blue: 0.95, alpha: 1)
        case .amber:
            light = UIColor(red: 0.48, green: 0.28, blue: 0, alpha: 1)
            dark = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)
        case .monochrome:
            light = .black
            dark = .white
        }
        return Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    static func colorScheme(for appearance: AppAppearance) -> ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}
