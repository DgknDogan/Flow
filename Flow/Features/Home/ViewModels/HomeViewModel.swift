import Foundation
import Observation

@Observable
final class HomeViewModel {

    var selectedDate: Date = .now
    var selectedMonth: Int = Calendar.current.component(.month, from: .now)
    var searchText = ""

    /// Seçilen ay bu aydan sonraysa geçen yılın o ayı kastedilir; gelecek ayların verisi olmaz.
    var selectedYear: Int {
        Self.year(forMonth: selectedMonth, relativeTo: .now)
    }

    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    /// Seçili güne ait işlemler; arama varsa kategori adı ya da notla eşleşenler.
    func visibleTransactions(in transactions: [Transaction], calendar: Calendar = .current, locale: Locale = .current) -> [Transaction] {
        let dayTransactions = transactions.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        let query = trimmedSearchText
        guard !query.isEmpty else { return dayTransactions }
        return dayTransactions.filter { $0.matches(query, locale: locale) }
    }

    static func year(forMonth month: Int, relativeTo date: Date, calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        return month > (components.month ?? 12) ? year - 1 : year
    }
}
