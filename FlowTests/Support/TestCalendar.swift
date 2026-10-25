import Testing
import Foundation

/// Saat diliminden ve bölgeden bağımsız tarih hesapları için sabit takvim (Gregoryen, UTC,
/// hafta pazar başlar).
enum TestCalendar {

    static let gmt: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) throws -> Date {
        try #require(gmt.date(from: DateComponents(year: year, month: month, day: day, hour: hour)))
    }
}
