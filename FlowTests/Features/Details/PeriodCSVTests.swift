import Testing
import Foundation
@testable import Flow

/// "Şimdi" 15 Mart 2026 (pazar, UTC); hafta pazar başlar.
@Suite("PeriodCSV")
struct PeriodCSVTests {

    private let calendar = TestCalendar.gmt
    private let english = Locale(identifier: "en")

    @Test func monthContainsOnlyItsTransactionsInDateOrder() throws {
        let csv = try export([
            .mock(amount: 1_000, type: .income, category: IncomeCategory.salary.rawValue, date: TestCalendar.date(2026, 3, 20, hour: 9)),
            .mock(amount: 12.5, type: .expense, category: ExpenseCategory.dining.rawValue, date: TestCalendar.date(2026, 3, 2, hour: 14)),
            .mock(amount: 50, type: .expense, date: TestCalendar.date(2026, 2, 28)),
            .mock(amount: 70, type: .expense, date: TestCalendar.date(2026, 4, 1, hour: 0))
        ], range: .month)

        let dining = ExpenseCategory.dining.displayName.localized(in: english)
        let salary = IncomeCategory.salary.displayName.localized(in: english)
        #expect(lines(csv) == [
            "Date,Transaction Type,Category,Amount,Currency,Note",
            "2026-03-02 14:00,Expense,\(dining),-12.5,TRY,",
            "2026-03-20 09:00,Income,\(salary),1000,TRY,"
        ])
        #expect(csv.text.hasSuffix("\r\n"))
    }

    @Test func filenameFollowsTheSelectedPeriod() throws {
        #expect(try export([], range: .week).filename == "Flow-2026-03-15_2026-03-21")
        #expect(try export([], range: .month).filename == "Flow-2026-03")
        #expect(try export([], range: .year).filename == "Flow-2026")
    }

    @Test func weekAndYearUseTheirOwnRange() throws {
        let transactions: [Transaction] = [
            .mock(date: try TestCalendar.date(2026, 3, 14)),
            .mock(date: try TestCalendar.date(2026, 3, 16)),
            .mock(date: try TestCalendar.date(2026, 11, 3)),
            .mock(date: try TestCalendar.date(2025, 12, 31))
        ]

        #expect(lines(try export(transactions, range: .week)).count == 2)
        #expect(lines(try export(transactions, range: .year)).count == 4)
    }

    @Test func notesAreEscaped() throws {
        let csv = try export([
            .mock(date: TestCalendar.date(2026, 3, 3), note: "Coffee, \"large\"\nwith cake"),
            .mock(date: TestCalendar.date(2026, 3, 4), note: "=SUM(A1:A2)")
        ], range: .month)

        #expect(csv.text.contains(",\"Coffee, \"\"large\"\"\nwith cake\"\r\n"))
        #expect(csv.text.contains(",'=SUM(A1:A2)\r\n"))
    }

    // MARK: - Helpers

    private func export(_ transactions: [Transaction], range: DateTabs) throws -> PeriodCSV {
        PeriodCSV(
            transactions: transactions,
            range: range,
            interval: range.interval(containing: try TestCalendar.date(2026, 3, 15), calendar: calendar),
            currencyCode: "TRY",
            locale: english,
            calendar: calendar
        )
    }

    private func lines(_ csv: PeriodCSV) -> [String] {
        csv.text.components(separatedBy: "\r\n").filter { !$0.isEmpty }
    }
}
