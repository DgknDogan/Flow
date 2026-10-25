import Foundation

nonisolated struct Transaction: Identifiable, Hashable, Sendable {
    let id: UUID
    var amount: Decimal
    var kind: TransactionKind
    var category: String
    var date: Date
    var note: String?
    let createdAt: Date
    var updatedAt: Date

    /// Gelirler pozitif, giderler negatif; tutarın yönünü renkten bağımsız göstermek için.
    var signedAmount: Decimal {
        kind == .income ? amount : -amount
    }

    var transactionType: TransactionType {
        switch kind {
        case .income:
            return .income(IncomeCategory(rawValue: category) ?? .other)
        case .expense:
            return .expense(ExpenseCategory(rawValue: category) ?? .other)
        }
    }
}
