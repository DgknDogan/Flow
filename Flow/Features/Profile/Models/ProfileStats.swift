import Foundation

/// Profil ekranındaki özet kartlarının verisi.
nonisolated struct ProfileStats {

    let transactionCount: Int
    let activeDays: Int
    let totalExpense: Decimal
    let topCategory: (category: ExpenseCategory, amount: Decimal)?

    init(transactions: [Transaction]) {
        let calendar = Calendar.current
        transactionCount = transactions.count
        activeDays = Set(transactions.map { calendar.startOfDay(for: $0.date) }).count

        var expense: Decimal = 0
        var expenseByCategory: [ExpenseCategory: Decimal] = [:]

        for transaction in transactions {
            guard case .expense(let category) = transaction.transactionType else { continue }
            expense += transaction.amount
            expenseByCategory[category, default: 0] += transaction.amount
        }

        totalExpense = expense
        topCategory = expenseByCategory
            .max { $0.value < $1.value }
            .map { ($0.key, $0.value) }
    }

    var topCategoryShare: Double {
        guard let topCategory, totalExpense > 0 else { return 0 }
        return (topCategory.amount / totalExpense).doubleValue
    }
}
