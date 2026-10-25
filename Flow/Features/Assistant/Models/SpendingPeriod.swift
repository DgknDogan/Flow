import Foundation

/// Modelin aracı çağırırken seçtiği dönem. Tarih hesabını küçük modele bırakmamak için hazır
/// dönemler sunulur; `custom` yalnızca kullanıcı belirli tarihler verdiğinde kullanılır.
nonisolated enum SpendingPeriod: Equatable, CaseIterable {
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case lastMonth
    case thisYear
    case lastYear
    case last7Days
    case last30Days
    case allTime
    case custom

    /// Gemma aracının metin olarak verdiği dönem adı ("thisMonth"); büyük/küçük harf yok sayılır.
    init?(name: String) {
        let target = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let period = Self.allCases.first(where: { String(describing: $0).lowercased() == target }) else { return nil }
        self = period
    }

    /// Dönemin yarı açık aralığı [start, end). `custom` için tarihler gün olarak dahildir;
    /// eksik ya da ters sıralı tarihlerde `nil`.
    func interval(now: Date, calendar: Calendar, customStart: Date? = nil, customEnd: Date? = nil) -> DateInterval? {
        let today = calendar.startOfDay(for: now)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }

        switch self {
        case .today: return calendarInterval(.day, offset: 0, from: now, calendar: calendar)
        case .yesterday: return calendarInterval(.day, offset: -1, from: now, calendar: calendar)
        case .thisWeek: return calendarInterval(.weekOfYear, offset: 0, from: now, calendar: calendar)
        case .lastWeek: return calendarInterval(.weekOfYear, offset: -1, from: now, calendar: calendar)
        case .thisMonth: return calendarInterval(.month, offset: 0, from: now, calendar: calendar)
        case .lastMonth: return calendarInterval(.month, offset: -1, from: now, calendar: calendar)
        case .thisYear: return calendarInterval(.year, offset: 0, from: now, calendar: calendar)
        case .lastYear: return calendarInterval(.year, offset: -1, from: now, calendar: calendar)
        case .last7Days: return trailingDays(7, endingAt: tomorrow, calendar: calendar)
        case .last30Days: return trailingDays(30, endingAt: tomorrow, calendar: calendar)
        case .allTime: return DateInterval(start: .distantPast, end: tomorrow)
        case .custom:
            guard let customStart, let customEnd else { return nil }
            let start = calendar.startOfDay(for: customStart)
            guard let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: customEnd)),
                  start < end
            else { return nil }
            return DateInterval(start: start, end: end)
        }
    }

    /// Karşılaştırma için bir önceki dönem: takvim dönemlerinde bir önceki tam dönem, diğerlerinde
    /// hemen öncesindeki aynı uzunlukta aralık. Tüm zamanlar için `nil`.
    func previousInterval(of interval: DateInterval, calendar: Calendar) -> DateInterval? {
        switch self {
        case .today, .yesterday:
            return calendarInterval(.day, offset: -1, from: interval.start, calendar: calendar)
        case .thisWeek, .lastWeek:
            return calendarInterval(.weekOfYear, offset: -1, from: interval.start, calendar: calendar)
        case .thisMonth, .lastMonth:
            return calendarInterval(.month, offset: -1, from: interval.start, calendar: calendar)
        case .thisYear, .lastYear:
            return calendarInterval(.year, offset: -1, from: interval.start, calendar: calendar)
        case .last7Days, .last30Days, .custom:
            guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return nil }
            return trailingDays(days, endingAt: interval.start, calendar: calendar)
        case .allTime:
            return nil
        }
    }

    private func calendarInterval(_ unit: Calendar.Component, offset: Int, from date: Date, calendar: Calendar) -> DateInterval? {
        calendar.date(byAdding: unit, value: offset, to: date).flatMap { calendar.dateInterval(of: unit, for: $0) }
    }

    private func trailingDays(_ days: Int, endingAt end: Date, calendar: Calendar) -> DateInterval? {
        calendar.date(byAdding: .day, value: -days, to: end).map { DateInterval(start: $0, end: end) }
    }
}
