import Testing
import Foundation
@testable import Flow

@Suite("ProfileStats")
struct ProfileStatsTests {

    @Test func summarizesTransactions() {
        let firstDay = Date(timeIntervalSince1970: 1_700_000_000)
        let laterDay = firstDay.addingTimeInterval(2 * 86_400)

        let stats = ProfileStats(transactions: [
            .mock(amount: 60, type: .expense, category: ExpenseCategory.dining.rawValue, date: firstDay),
            .mock(amount: 40, type: .expense, category: ExpenseCategory.transport.rawValue, date: firstDay),
            .mock(amount: 500, type: .income, category: IncomeCategory.salary.rawValue, date: laterDay)
        ])

        #expect(stats.transactionCount == 3)
        #expect(stats.activeDays == 2)
        #expect(stats.totalExpense == 100)
        #expect(stats.topCategory?.category == .dining)
        #expect(stats.topCategory?.amount == 60)
        #expect(abs(stats.topCategoryShare - 0.6) < 0.0001)
    }

    @Test func emptyHistoryHasNoTopCategory() {
        let stats = ProfileStats(transactions: [])

        #expect(stats.transactionCount == 0)
        #expect(stats.topCategory == nil)
        #expect(stats.topCategoryShare == 0)
    }
}
