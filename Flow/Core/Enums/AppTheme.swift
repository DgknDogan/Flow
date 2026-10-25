import SwiftUI

nonisolated enum AppTheme: String, CaseIterable, TitledOption {
    case system
    case light
    case dark

    var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var symbol: String {
        switch self {
        case .system: "iphone"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var tint: Color {
        switch self {
        case .system: .gray
        case .light: .orange
        case .dark: .indigo
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
