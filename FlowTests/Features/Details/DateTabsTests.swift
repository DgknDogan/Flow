import Testing
import Foundation
@testable import Flow

@Suite("DateTabs")
struct DateTabsTests {

    private let calendar = TestCalendar.gmt

    @Test func rangesAreShownWeekMonthYear() {
        #expect(DateTabs.allCases == [.week, .month, .year])
    }

    @Test(arguments: [
        (DateTabs.week, 7),
        (.month, 31),
        (.year, 365)
    ])
    func intervalContainsTheWholePeriod(range: DateTabs, days: Int) throws {
        let date = try TestCalendar.date(2026, 3, 18)

        let interval = range.interval(containing: date, calendar: calendar)

        #expect(interval.containsHalfOpen(date))
        #expect(calendar.dateComponents([.day], from: interval.start, to: interval.end).day == days)
    }

    @Test func shiftingMovesWholePeriods() throws {
        let march = DateTabs.month.interval(containing: try TestCalendar.date(2026, 3, 18), calendar: calendar)

        let february = DateTabs.month.interval(shiftedBy: -1, from: march, calendar: calendar)
        let april = DateTabs.month.interval(shiftedBy: 1, from: march, calendar: calendar)

        #expect(february.start == (try TestCalendar.date(2026, 2, 1, hour: 0)))
        #expect(february.end == march.start)
        #expect(april.start == march.end)
    }

    @Test func weekShiftsBySevenDays() throws {
        let week = DateTabs.week.interval(containing: try TestCalendar.date(2026, 3, 18), calendar: calendar)

        let previous = DateTabs.week.interval(shiftedBy: -1, from: week, calendar: calendar)

        #expect(previous.end == week.start)
        #expect(previous.duration == 7 * 24 * 60 * 60)
    }

    @Test func dayBasedRangesShareDailyLabels() {
        #expect(DateTabs.week.chartUnit == .day)
        #expect(DateTabs.month.chartUnit == .day)
        #expect(DateTabs.year.chartUnit == .month)
    }

    @Test func halfOpenIntervalExcludesItsEnd() throws {
        let start = try TestCalendar.date(2026, 3, 1, hour: 0)
        let interval = DateInterval(start: start, duration: 60)

        #expect(interval.containsHalfOpen(start))
        #expect(!interval.containsHalfOpen(interval.end))
        #expect(interval.contains(interval.end), "Foundation'ın contains'i bitişi kapsar")
    }
}
