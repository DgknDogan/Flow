import Foundation

nonisolated enum TransactionType: Equatable, Hashable {
    case income(IncomeCategory)
    case expense(ExpenseCategory)

    var details: any CategoryProtocol {
        switch self {
        case .income(let category): return category
        case .expense(let category): return category
        }
    }

    var kind: TransactionKind {
        switch self {
        case .income: return .income
        case .expense: return .expense
        }
    }
}
