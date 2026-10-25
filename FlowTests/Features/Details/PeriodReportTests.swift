import Testing
import Foundation
@testable import Flow

/// "Şimdi" 15 Mart 2026 öğlen (UTC); Mart 31 gün, 15'i dahil 15 gün geçmiş.
@Suite("PeriodReport")
struct PeriodReportTests {

    private let calendar = TestCalendar.gmt
    private let now: Date

    init() throws {
        now = try TestCalendar.date(2026, 3, 15)
    }

    // MARK: - Totals

    @Test func totalsCoverOnlyThePeriod() throws {
        let report = try monthReport([
            .mock(amount: 30, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 50, type: .expense, date: TestCalendar.date(2026, 2, 28)),
            .mock(amount: 1_000, type: .income, category: IncomeCategory.salary.rawValue, date: TestCalendar.date(2026, 3, 1))
        ])

        #expect(report.totalExpense == 30)
        #expect(report.totalIncome == 1_000)
        #expect(report.netBalance == 970)
        #expect(report.transactionCount == 2)
        #expect(!report.isEmpty)
    }

    /// Ayın son anı o aya, bir sonraki ayın ilk anı sonraki aya aittir.
    @Test func periodIsHalfOpen() throws {
        let lastMoment = DateComponents(year: 2026, month: 3, day: 31, hour: 23, minute: 59, second: 59, nanosecond: 500_000_000)
        let report = try monthReport([
            .mock(amount: 7, type: .expense, date: #require(calendar.date(from: lastMoment))),
            .mock(amount: 9, type: .expense, date: TestCalendar.date(2026, 4, 1, hour: 0))
        ])

        #expect(report.totalExpense == 7)
    }

    @Test func emptyPeriod() {
        let report = report([])

        #expect(report.isEmpty)
        #expect(report.totalExpense == 0)
        #expect(report.expenseCategories.isEmpty)
        #expect(report.incomeCategories.isEmpty)
        #expect(report.largestExpenses.isEmpty)
        #expect(report.peak == nil)
        #expect(report.savingsRate == nil)
        #expect(report.projectedExpense == nil)
    }

    // MARK: - Chart

    @Test(arguments: [(DateTabs.week, 7), (.month, 31), (.year, 12)])
    func chartHasOneBarPerSlot(range: DateTabs, count: Int) {
        let report = report([], range: range)

        #expect(report.chartData.count == count)
        #expect(report.chartData.allSatisfy { $0.amount == 0 })
    }

    @Test func monthBarsSumEachDay() throws {
        let day = try TestCalendar.date(2026, 3, 2)
        let report = try monthReport([
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 2, hour: 9)),
            .mock(amount: 15, type: .expense, date: TestCalendar.date(2026, 3, 2, hour: 18)),
            .mock(amount: 500, type: .income, date: day)
        ])

        let bar = try #require(report.chartData.first { calendar.isDate($0.date, inSameDayAs: day) })
        #expect(bar.amount == 25, "Gelirler grafiğe girmez")
    }

    @Test func yearBarsSumEachMonth() throws {
        let report = try self.report([
            .mock(amount: 20, type: .expense, date: TestCalendar.date(2026, 1, 10)),
            .mock(amount: 5, type: .expense, date: TestCalendar.date(2026, 1, 20)),
            .mock(amount: 30, type: .expense, date: TestCalendar.date(2026, 3, 2))
        ], range: .year)

        #expect(report.chartData.map(\.amount) == [25, 0, 30, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        #expect(report.totalExpense == 55)
    }

    /// Hafta takvimin ilk gününden (burada pazar) başlar.
    @Test func weekStartsOnCalendarsFirstWeekday() throws {
        let report = try self.report([
            .mock(amount: 8, type: .expense, date: TestCalendar.date(2026, 3, 14)),
            .mock(amount: 4, type: .expense, date: TestCalendar.date(2026, 3, 16))
        ], range: .week)

        #expect(report.interval.start == (try TestCalendar.date(2026, 3, 15, hour: 0)))
        #expect(report.totalExpense == 4)
        #expect(report.previousTotalExpense == 8)
    }

    // MARK: - Categories

    @Test func categoriesAreSortedWithSharesAndCounts() throws {
        let day = try TestCalendar.date(2026, 3, 5)
        let report = monthReport(at: day, [
            (10, .health), (60, .dining), (20, .transport), (10, .transport)
        ])

        #expect(report.expenseCategories.map(\.category) == [.dining, .transport, .health])
        #expect(report.expenseCategories.map(\.transactionCount) == [1, 2, 1])
        #expect(abs(report.expenseCategories[0].share - 0.6) < 0.0001)
        #expect(abs(report.expenseCategories[2].share - 0.1) < 0.0001)
    }

    @Test func allCategoriesAreListed() throws {
        let day = try TestCalendar.date(2026, 3, 5)
        let categories: [ExpenseCategory] = [.housing, .utilities, .dining, .groceries, .transport, .shopping, .health]
        let report = monthReport(at: day, categories.enumerated().map { (Decimal($0.offset + 1), $0.element) })

        #expect(report.expenseCategories.count == categories.count)
        #expect(report.expenseCategories.first?.category == .health)
    }

    @Test func equalAmountsAreOrderedByCategoryKey() throws {
        let day = try TestCalendar.date(2026, 3, 5)
        let report = monthReport(at: day, [(10, .travel), (10, .dining)])

        #expect(report.expenseCategories.map(\.category) == [.dining, .travel])
    }

    // MARK: - Largest expenses

    @Test func largestExpensesAreLimitedAndSorted() throws {
        let day = try TestCalendar.date(2026, 3, 5)
        let amounts: [Decimal] = [5, 80, 20, 60, 10, 40, 1]
        let transactions = amounts.map { Transaction.mock(amount: $0, type: .expense, date: day) }
            + [.mock(amount: 9_999, type: .income, date: day)]

        let report = report(transactions)

        #expect(report.largestExpenses.map(\.amount) == [80, 60, 40, 20, 10])
    }

    @Test func equalLargestExpensesShowNewestFirst() throws {
        let older = Transaction.mock(amount: 50, type: .expense, date: try TestCalendar.date(2026, 3, 1))
        let newer = Transaction.mock(amount: 50, type: .expense, date: try TestCalendar.date(2026, 3, 9))

        let report = report([older, newer])

        #expect(report.largestExpenses.map(\.id) == [newer.id, older.id])
    }

    // MARK: - Insights

    @Test func comparesWithPreviousPeriod() throws {
        let report = try monthReport([
            .mock(amount: 80, type: .expense, date: TestCalendar.date(2026, 2, 10)),
            .mock(amount: 100, type: .expense, date: TestCalendar.date(2026, 3, 10))
        ])

        #expect(report.previousTotalExpense == 80)
        #expect(abs(try #require(report.expenseChange) - 0.25) < 0.0001)
    }

    @Test func noComparisonWithoutPreviousSpending() throws {
        let report = try monthReport([.mock(amount: 100, type: .expense, date: TestCalendar.date(2026, 3, 10))])

        #expect(report.expenseChange == nil)
    }

    /// Ortalama yalnızca geçen günlere bölünür; projeksiyon ayın tamamına uzatır.
    @Test func averageAndProjectionUseElapsedDays() throws {
        let report = try monthReport([.mock(amount: 150, type: .expense, date: TestCalendar.date(2026, 3, 3))])

        #expect(report.elapsedDayCount == 15)
        #expect(report.averageExpense == 10)
        #expect(report.projectedExpense == 310)
    }

    @Test func pastPeriodAveragesAllDaysWithoutProjection() throws {
        let february = try TestCalendar.date(2026, 2, 10)
        let report = PeriodReport(
            transactions: [.mock(amount: 280, type: .expense, date: february)],
            range: .month,
            interval: DateTabs.month.interval(containing: february, calendar: calendar),
            now: now,
            calendar: calendar
        )

        #expect(!report.isCurrentPeriod)
        #expect(report.elapsedDayCount == 28)
        #expect(report.averageExpense == 10)
        #expect(report.projectedExpense == nil)
    }

    @Test func peakIsTheBusiestSlot() throws {
        let report = try monthReport([
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 70, type: .expense, date: TestCalendar.date(2026, 3, 9)),
            .mock(amount: 30, type: .expense, date: TestCalendar.date(2026, 3, 12))
        ])

        let peak = try #require(report.peak)
        #expect(calendar.isDate(peak.date, inSameDayAs: try TestCalendar.date(2026, 3, 9)))
        #expect(peak.amount == 70)
    }

    @Test func noSpendDaysCountElapsedDaysWithoutExpenses() throws {
        let report = try monthReport([
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 2, hour: 20)),
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 5)),
            .mock(amount: 500, type: .income, date: TestCalendar.date(2026, 3, 6)),
            // İleri tarihli gider henüz geçmemiş bir güne ait; sayılmaz.
            .mock(amount: 10, type: .expense, date: TestCalendar.date(2026, 3, 20))
        ])

        #expect(report.noSpendDayCount == 13)
    }

    @Test func savingsRateIsShareOfIncomeKept() throws {
        let saving = try monthReport([
            .mock(amount: 1_000, type: .income, date: TestCalendar.date(2026, 3, 1)),
            .mock(amount: 250, type: .expense, date: TestCalendar.date(2026, 3, 2))
        ])
        let overspending = try monthReport([
            .mock(amount: 100, type: .income, date: TestCalendar.date(2026, 3, 1)),
            .mock(amount: 150, type: .expense, date: TestCalendar.date(2026, 3, 2))
        ])

        #expect(saving.savingsRate == 0.75)
        #expect(overspending.savingsRate == -0.5)
    }

    // MARK: - Budget

    @Test func noBudgetWithoutDailyLimit() {
        let report = report([])

        #expect(report.budget(dailyLimit: nil) == nil)
        #expect(report.budget(dailyLimit: 0) == nil)
    }

    @Test func budgetUsesEveryDayOfThePeriod() throws {
        let report = try monthReport([
            .mock(amount: 60, type: .expense, date: TestCalendar.date(2026, 3, 2)),
            .mock(amount: 40, type: .expense, date: TestCalendar.date(2026, 3, 3)),
            .mock(amount: 75, type: .expense, date: TestCalendar.date(2026, 3, 4))
        ])

        let budget = try #require(report.budget(dailyLimit: 50))

        #expect(budget.limit == 1_550)
        #expect(budget.spent == 175)
        #expect(budget.remaining == 1_375)
        #expect(budget.daysOverLimit == 2)
        #expect(!budget.isOverBudget)
        #expect(abs(budget.progress - 175.0 / 1_550.0) < 0.0001)
        // Bugün dahil 17 gün kaldı.
        #expect(budget.dailyAllowance == Decimal(1_375) / 17)
    }

    @Test func overBudgetHasNoAllowance() throws {
        let report = try monthReport([.mock(amount: 400, type: .expense, date: TestCalendar.date(2026, 3, 2))])

        let budget = try #require(report.budget(dailyLimit: 10))

        #expect(budget.isOverBudget)
        #expect(budget.remaining == -90)
        #expect(budget.dailyAllowance == nil)
    }

    @Test func pastPeriodBudgetHasNoAllowance() throws {
        let february = try TestCalendar.date(2026, 2, 10)
        let report = PeriodReport(
            transactions: [],
            range: .month,
            interval: DateTabs.month.interval(containing: february, calendar: calendar),
            now: now,
            calendar: calendar
        )

        let budget = try #require(report.budget(dailyLimit: 10))

        #expect(budget.limit == 280)
        #expect(budget.dailyAllowance == nil)
    }

    @Test func dailyLimitIsRoundedToCents() throws {
        let budget = try #require(report([]).budget(dailyLimit: 0.1))

        #expect(budget.dailyLimit == Decimal(string: "0.1"))
    }

    // MARK: - Helpers

    private func report(_ transactions: [Transaction], range: DateTabs = .month) -> PeriodReport {
        PeriodReport(
            transactions: transactions,
            range: range,
            interval: range.interval(containing: now, calendar: calendar),
            now: now,
            calendar: calendar
        )
    }

    private func monthReport(_ transactions: [Transaction]) -> PeriodReport {
        report(transactions)
    }

    private func monthReport(at day: Date, _ expenses: [(Decimal, ExpenseCategory)]) -> PeriodReport {
        report(expenses.map { Transaction.mock(amount: $0.0, type: .expense, category: $0.1.rawValue, date: day) })
    }
}
