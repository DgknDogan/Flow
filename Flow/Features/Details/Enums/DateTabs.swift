import Foundation

/// Details'te özetlenen dönem türü.
nonisolated enum DateTabs: CaseIterable, TitledOption {
    case week
    case month
    case year

    var title: LocalizedStringResource {
        switch self {
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }

    var chartTitle: LocalizedStringResource {
        switch self {
        case .week: "Weekly Expenses"
        case .month: "Monthly Expenses"
        case .year: "Yearly Expenses"
        }
    }

    var emptyChartMessage: LocalizedStringResource {
        switch self {
        case .week: "No expenses this week"
        case .month: "No expenses this month"
        case .year: "No expenses this year"
        }
    }

    /// İçinde bulunulan döneme dönme butonunun başlığı.
    var currentPeriodTitle: LocalizedStringResource {
        switch self {
        case .week: "This Week"
        case .month: "This Month"
        case .year: "This Year"
        }
    }

    var comparisonTitle: LocalizedStringResource {
        switch self {
        case .week: "vs. Previous Week"
        case .month: "vs. Previous Month"
        case .year: "vs. Previous Year"
        }
    }

    var projectionSubtitle: LocalizedStringResource {
        switch self {
        case .week: "At this pace by the end of the week"
        case .month: "At this pace by the end of the month"
        case .year: "At this pace by the end of the year"
        }
    }

    // MARK: - Grafik dilimi (gün ya da ay)

    /// Grafikteki her çubuğun kapsadığı süre.
    var chartUnit: Calendar.Component {
        switch self {
        case .week, .month: .day
        case .year: .month
        }
    }

    var averageTitle: LocalizedStringResource {
        chartUnit == .day ? "Daily Average" : "Monthly Average"
    }

    var averageLegend: LocalizedStringResource {
        chartUnit == .day ? "Daily average" : "Monthly average"
    }

    var limitLegend: LocalizedStringResource {
        chartUnit == .day ? "Daily limit" : "Monthly limit"
    }

    var peakTitle: LocalizedStringResource {
        chartUnit == .day ? "Busiest Day" : "Busiest Month"
    }

    /// Grafikte seçilen ya da en çok harcanan dilimin tarihi.
    var slotDateFormat: Date.FormatStyle {
        chartUnit == .day ? .dateTime.weekday(.wide).month(.wide).day() : .dateTime.month(.wide).year()
    }

    // MARK: - Dönem aralığı

    /// Özetlenen dönem: hafta, ay ya da yıl.
    var rangeUnit: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }

    /// Tarihi içeren dönem; hafta başı takvimin (bölgenin) ilk gününe göredir.
    func interval(containing date: Date, calendar: Calendar) -> DateInterval {
        calendar.dateInterval(of: rangeUnit, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 24 * 60 * 60)
    }

    /// Verilen dönemden `periods` kadar önceki (negatif) ya da sonraki dönem.
    func interval(shiftedBy periods: Int, from interval: DateInterval, calendar: Calendar) -> DateInterval {
        let shifted = calendar.date(byAdding: rangeUnit, value: periods, to: interval.start) ?? interval.start
        return self.interval(containing: shifted, calendar: calendar)
    }

    /// Dönem başlığı: "Oct 19 – 25, 2026", "October 2026" ya da "2026".
    func title(for interval: DateInterval, locale: Locale = .current) -> String {
        switch self {
        case .week:
            let lastMoment = interval.end.addingTimeInterval(-1)
            return (interval.start..<lastMoment).formatted(.interval.month(.abbreviated).day().year().locale(locale))
        case .month:
            return interval.start.formatted(.dateTime.month(.wide).year().locale(locale))
        case .year:
            return interval.start.formatted(.dateTime.year().locale(locale))
        }
    }
}
