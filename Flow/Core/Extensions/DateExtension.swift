import Foundation

nonisolated extension Date {

    /// Verilen ayın her günü için gece yarısı tarihleri.
    static func daysInMonth(month: Int, year: Int, calendar: Calendar = .current) -> [Date] {
        guard
            let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
            let range = calendar.range(of: .day, in: .month, for: firstDay)
        else { return [] }

        return range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: firstDay)
        }
    }

    /// `date` dahil son `count` ayın ilk günleri, eskiden yeniye sıralı.
    static func recentMonthStarts(count: Int = 12, endingAt date: Date = .now, calendar: Calendar = .current) -> [Date] {
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: date)?.start else { return [] }
        return (0..<count).reversed().compactMap {
            calendar.date(byAdding: .month, value: -$0, to: currentMonthStart)
        }
    }

    /// İçinde bulunulan ayın gün sayısı; aylık limit = günlük limit × bu değer.
    static var daysInCurrentMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: .now)?.count ?? 30
    }
}
