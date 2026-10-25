import SwiftUI

enum Tabs: Hashable, CaseIterable {
    case home
    case details
    case settings
    case assistant

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .details: "chart.bar.fill"
        case .settings: "gear"
        case .assistant: "sparkles"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .home: "Home"
        case .details: "Details"
        case .settings: "Settings"
        case .assistant: "Assistant"
        }
    }
}
