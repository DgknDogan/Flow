import SwiftUI

nonisolated enum ExpenseCategory: String, CategoryProtocol {
    // Ham değerler kayıtlı verinin anahtarıdır; görünen adı değiştirmek için `displayName` kullanılır.
    case housing = "Housing"
    case utilities = "Utilities"
    case dining = "Dining Out"
    case groceries = "Groceries"
    case transport = "Transportation"
    case shopping = "Shopping"
    case health = "Health"
    case education = "Education"
    case travel = "Travel"
    case subscriptions = "Subscriptions"
    case entertainment = "Entertainment"
    case other = "Other"

    var displayName: LocalizedStringResource {
        switch self {
        case .housing: "Housing"
        case .utilities: "Utilities"
        case .dining: "Dining Out"
        case .groceries: "Groceries"
        case .transport: "Transportation"
        case .shopping: "Shopping"
        case .health: "Health"
        case .education: "Education"
        case .travel: "Travel"
        case .subscriptions: "Subscriptions"
        case .entertainment: "Entertainment"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .housing: "house.fill"
        case .utilities: "lightbulb.fill"
        case .dining: "fork.knife"
        case .groceries: "cart.fill"
        case .transport: "car.fill"
        case .shopping: "bag.fill"
        case .health: "heart.fill"
        case .education: "book.fill"
        case .travel: "airplane"
        case .subscriptions: "calendar.badge.clock"
        case .entertainment: "gamecontroller.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .housing: .blue
        case .utilities: .orange
        case .dining: .red
        case .groceries: .green
        case .transport: .purple
        case .shopping: .pink
        case .health: .red
        case .education: .cyan
        case .travel: .teal
        case .subscriptions: .indigo
        case .entertainment: .yellow
        case .other: .gray
        }
    }
}
