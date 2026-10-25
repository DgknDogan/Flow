import Testing
import Foundation
@testable import Flow

@Suite("SpendingSummary")
struct SpendingSummaryTests {

    private let calendar = TestCalendar.gmt
    private let english = Locale(identifier: "en_US")
    private let march: DateInterval
    private let february: DateInterval

    init() throws {
        march = DateInterval(start: try TestCalendar.date(2026, 3, 1, hour: 0), end: try TestCalendar.date(2026, 4, 1, hour: 0))
        february = DateInterval(start: try TestCalendar.date(2026, 2, 1, hour: 0), end: march.start)
    }

    @Test func totalsCoverOnlyThePeriod() throws {
        let summary = try makeSummary([
            .mock(amount: 30, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 20, type: .expense, category: ExpenseCategory.groceries.rawValue, date: TestCalendar.date(2026, 3, 5)),
            .mock(amount: 1_000, type: .income, category: IncomeCategory.salary.rawValue, date: TestCalendar.date(2026, 3, 1)),
            .mock(amount: 40, type: .expense, date: TestCalendar.date(2026, 2, 20))
        ])

        #expect(summary.totalExpense == 50)
        #expect(summary.expenseCount == 2)
        #expect(summary.totalIncome == 1_000)
        #expect(summary.incomeCount == 1)
        #expect(summary.previousTotalExpense == 40)
        #expect(summary.expenseChange == 0.25)
        #expect(summary.expenseCategories.map(\.category) == [.dining, .groceries])
    }

    @Test func categoryFilterKeepsOnlyMatchingTransactions() throws {
        let filter = SpendingSummary.CategoryFilter(kind: .expense, rawValue: ExpenseCategory.dining.rawValue)
        let summary = try makeSummary([
            .mock(amount: 30, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 20, type: .expense, category: ExpenseCategory.groceries.rawValue, date: TestCalendar.date(2026, 3, 5)),
            .mock(amount: 10, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 2, 5))
        ], filter: filter)

        #expect(summary.totalExpense == 30)
        #expect(summary.previousTotalExpense == 10)
    }

    /// Süzülmüş raporda genel toplam ve pay hazır verilir; model "%100" demesin.
    @Test func categoryFilterReportsShareOfAllCategories() throws {
        let filter = SpendingSummary.CategoryFilter(kind: .expense, rawValue: ExpenseCategory.transport.rawValue)
        let summary = try makeSummary([
            .mock(amount: 45, type: .expense, category: ExpenseCategory.transport.rawValue, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 120, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 3)),
            .mock(amount: 5_000, type: .income, category: IncomeCategory.salary.rawValue, date: TestCalendar.date(2026, 3, 1)),
            .mock(amount: 80, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 2, 3))
        ], filter: filter)

        #expect(summary.totalExpense == 45)
        #expect(summary.unfilteredTotal == 165)
        #expect(abs((summary.filteredShare ?? 0) - 45.0 / 165.0) < 0.0001)

        let report = summary.report(currency: .dollar, locale: english, calendar: calendar)
        #expect(report.contains("All expenses in this period, all categories: $165.00; this category's share: 27%"))
    }

    @Test func unfilteredReportHasNoShareLine() throws {
        let summary = try makeSummary([
            .mock(amount: 45, type: .expense, category: ExpenseCategory.transport.rawValue, date: TestCalendar.date(2026, 3, 2))
        ])

        #expect(summary.unfilteredTotal == nil)
        #expect(!summary.report(currency: .dollar, locale: english, calendar: calendar).contains("all categories"))
    }

    @Test func largestExpensesAreSortedAndLimited() throws {
        let transactions = try (1...7).map { day in
            Transaction.mock(amount: Decimal(day * 10), type: .expense, date: try TestCalendar.date(2026, 3, day))
        }
        let summary = try makeSummary(transactions)

        #expect(summary.largestExpenses.count == SpendingSummary.largestExpenseLimit)
        #expect(summary.largestExpenses.map(\.amount) == [70, 60, 50, 40, 30])
    }

    @Test(arguments: ["Dining Out", "dining out", "  Groceries "])
    func categoryMatchesRawValueIgnoringCase(name: String) {
        #expect(SpendingSummary.categoryFilter(matching: name, locale: english)?.kind == .expense)
    }

    @Test func categoryMatchesIncome() {
        let filter = SpendingSummary.categoryFilter(matching: "Salary", locale: english)
        #expect(filter == SpendingSummary.CategoryFilter(kind: .income, rawValue: IncomeCategory.salary.rawValue))
    }

    @Test func unknownCategoryHasNoFilter() {
        #expect(SpendingSummary.categoryFilter(matching: "Crypto", locale: english) == nil)
        #expect(SpendingSummary.categoryFilter(matching: " ", locale: english) == nil)
    }

    @Test func reportListsTotalsAndComparison() throws {
        let summary = try makeSummary([
            .mock(amount: 30, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 2), note: "Pizza"),
            .mock(amount: 20, type: .expense, date: TestCalendar.date(2026, 2, 20))
        ])

        let report = summary.report(currency: .dollar, locale: english, calendar: calendar)

        #expect(report.contains("Period: 2026-03-01 to 2026-03-31"))
        #expect(report.contains("Total expenses: $30.00 (1 transactions)"))
        #expect(report.contains("change: +50%"))
        #expect(report.contains("\"Pizza\""))
    }

    @Test func emptyReportSaysSo() throws {
        let report = try makeSummary([]).report(currency: .dollar, locale: english, calendar: calendar)
        #expect(report.contains("No transactions recorded in this period."))
    }

    private func makeSummary(_ transactions: [Transaction], filter: SpendingSummary.CategoryFilter? = nil) throws -> SpendingSummary {
        SpendingSummary(transactions: transactions, interval: march, previousInterval: february, filter: filter)
    }
}
