import SwiftUI

/// Onboarding sayfaları; sıra `allCases` sırasıdır.
nonisolated enum OnboardingStep: SequentialCase {
    case tracking
    case budgeting
    case insights

    var title: LocalizedStringResource {
        switch self {
        case .tracking: "Track Every Penny"
        case .budgeting: "Master Your Budget"
        case .insights: "Gain Financial Insights"
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .tracking: "Categorize your daily expenses instantly and see exactly where your money goes."
        case .budgeting: "Set monthly limits for different categories and reach your savings goals faster."
        case .insights: "Understand your spending habits through detailed analytics and prepare for the future."
        }
    }

    var color: Color {
        switch self {
        case .tracking: .blue
        case .budgeting: .yellow
        case .insights: .purple
        }
    }
}

extension OnboardingStep {
    /// Xcode'un ürettiği görsel sembolleri MainActor'a bağlı olduğundan bu özellik de öyle.
    @MainActor var image: ImageResource {
        switch self {
        case .tracking: .track
        case .budgeting: .budget
        case .insights: .insight
        }
    }
}
