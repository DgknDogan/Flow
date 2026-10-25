import SwiftUI

nonisolated enum IncomeCategory: String, CategoryProtocol {
    // Ham değerler kayıtlı verinin anahtarıdır; görünen adı değiştirmek için `displayName` kullanılır.
    case salary = "Salary"
    case freelance = "Freelance"
    case investment = "Investment"
    case gift = "Gift"
    case rental = "Rental Income"
    case bonus = "Bonus"
    case sales = "Sales"
    case refunds = "Refunds"
    case other = "Other"

    var displayName: LocalizedStringResource {
        switch self {
        case .salary: "Salary"
        case .freelance: "Freelance"
        case .investment: "Investment"
        case .gift: "Gift"
        case .rental: "Rental Income"
        case .bonus: "Bonus"
        case .sales: "Sales"
        case .refunds: "Refunds"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .salary: "banknote.fill"
        case .freelance: "laptopcomputer"
        case .investment: "chart.line.uptrend.xyaxis"
        case .gift: "gift.fill"
        case .rental: "key.fill"
        case .bonus: "star.fill"
        case .sales: "tag.fill"
        case .refunds: "arrow.counterclockwise.circle.fill"
        case .other: "plus.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .salary: .green
        case .freelance: .blue
        case .investment: .mint
        case .gift: .pink
        case .rental: .indigo
        case .bonus: .orange
        case .sales: .teal
        case .refunds: .red
        case .other: .gray
        }
    }
}
