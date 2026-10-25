import Testing
import Foundation
@testable import Flow

/// "Şimdi" 18 Mart 2026 Çarşamba öğlen (UTC); hafta pazar başlar.
@Suite("SpendingPeriod")
struct SpendingPeriodTests {

    private let calendar = TestCalendar.gmt
    private let now: Date

    init() throws {
        now = try TestCalendar.date(2026, 3, 18)
    }

    @Test func calendarPeriodsCoverWholeUnits() throws {
        let thisMonth = try #require(SpendingPeriod.thisMonth.interval(now: now, calendar: calendar))
        #expect(thisMonth.start == (try TestCalendar.date(2026, 3, 1, hour: 0)))
        #expect(thisMonth.end == (try TestCalendar.date(2026, 4, 1, hour: 0)))

        let lastMonth = try #require(SpendingPeriod.lastMonth.interval(now: now, calendar: calendar))
        #expect(lastMonth.start == (try TestCalendar.date(2026, 2, 1, hour: 0)))
        #expect(lastMonth.end == thisMonth.start)

        let thisWeek = try #require(SpendingPeriod.thisWeek.interval(now: now, calendar: calendar))
        #expect(thisWeek.start == (try TestCalendar.date(2026, 3, 15, hour: 0)))
    }

    /// Kayan dönemler bugünü de kapsar.
    @Test func trailingDaysIncludeToday() throws {
        let interval = try #require(SpendingPeriod.last7Days.interval(now: now, calendar: calendar))

        #expect(interval.start == (try TestCalendar.date(2026, 3, 12, hour: 0)))
        #expect(interval.end == (try TestCalendar.date(2026, 3, 19, hour: 0)))
    }

    @Test func customPeriodIncludesBothDays() throws {
        let interval = try #require(SpendingPeriod.custom.interval(
            now: now,
            calendar: calendar,
            customStart: TestCalendar.date(2026, 1, 10),
            customEnd: TestCalendar.date(2026, 1, 12)
        ))

        #expect(interval.start == (try TestCalendar.date(2026, 1, 10, hour: 0)))
        #expect(interval.end == (try TestCalendar.date(2026, 1, 13, hour: 0)))
    }

    @Test func customPeriodNeedsOrderedDates() throws {
        #expect(SpendingPeriod.custom.interval(now: now, calendar: calendar) == nil)
        #expect(SpendingPeriod.custom.interval(
            now: now,
            calendar: calendar,
            customStart: try TestCalendar.date(2026, 1, 12),
            customEnd: try TestCalendar.date(2026, 1, 10)
        ) == nil)
    }

    @Test func previousIntervalIsTheFullPreviousUnit() throws {
        let thisMonth = try #require(SpendingPeriod.thisMonth.interval(now: now, calendar: calendar))
        let previous = try #require(SpendingPeriod.thisMonth.previousInterval(of: thisMonth, calendar: calendar))

        #expect(previous.start == (try TestCalendar.date(2026, 2, 1, hour: 0)))
        #expect(previous.end == thisMonth.start)
    }

    @Test func previousIntervalOfTrailingDaysHasSameLength() throws {
        let last7Days = try #require(SpendingPeriod.last7Days.interval(now: now, calendar: calendar))
        let previous = try #require(SpendingPeriod.last7Days.previousInterval(of: last7Days, calendar: calendar))

        #expect(previous.end == last7Days.start)
        #expect(previous.duration == last7Days.duration)
    }

    @Test func allTimeHasNoPreviousInterval() throws {
        let allTime = try #require(SpendingPeriod.allTime.interval(now: now, calendar: calendar))
        #expect(SpendingPeriod.allTime.previousInterval(of: allTime, calendar: calendar) == nil)
    }

    /// Gemma aracı dönemi metin olarak verir.
    @Test func parsesPeriodNames() {
        #expect(SpendingPeriod(name: "thisMonth") == .thisMonth)
        #expect(SpendingPeriod(name: " LAST7DAYS ") == .last7Days)
        #expect(SpendingPeriod(name: "next month") == nil)
    }
}
