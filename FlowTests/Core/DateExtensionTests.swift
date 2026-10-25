import Testing
import Foundation
@testable import Flow

@Suite("Date extensions")
struct DateExtensionTests {

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    @Test(arguments: [(2024, 2, 29), (2026, 2, 28), (2026, 4, 30), (2026, 12, 31)])
    func daysInMonthCoversWholeMonth(year: Int, month: Int, expectedDays: Int) {
        let days = Date.daysInMonth(month: month, year: year, calendar: Self.calendar)

        #expect(days.count == expectedDays)
        #expect(days.map { Self.calendar.component(.day, from: $0) } == Array(1...expectedDays))
        #expect(days.allSatisfy { Self.calendar.component(.hour, from: $0) == 0 })
    }

    @Test func recentMonthsEndWithCurrentMonthInOrder() throws {
        let now = try #require(Self.calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 15)))

        let months = Date.recentMonthStarts(endingAt: now, calendar: Self.calendar)

        #expect(months.count == 12)
        #expect(months == months.sorted())
        #expect(months.last == Self.calendar.date(from: DateComponents(year: 2026, month: 10, day: 1)))
        #expect(months.first == Self.calendar.date(from: DateComponents(year: 2025, month: 11, day: 1)))
    }

    @Test func recentMonthsCrossYearBoundary() throws {
        let january = try #require(Self.calendar.date(from: DateComponents(year: 2026, month: 1, day: 5)))

        let months = Date.recentMonthStarts(count: 3, endingAt: january, calendar: Self.calendar)

        #expect(months.map { Self.calendar.component(.month, from: $0) } == [11, 12, 1])
        #expect(months.map { Self.calendar.component(.year, from: $0) } == [2025, 2025, 2026])
    }

    @Test func zeroRecentMonthsIsEmpty() {
        #expect(Date.recentMonthStarts(count: 0).isEmpty)
    }

    @Test func daysInCurrentMonthMatchesCalendar() {
        let expected = Calendar.current.range(of: .day, in: .month, for: .now)?.count
        #expect(Date.daysInCurrentMonth == expected)
    }
}
