import Foundation

/// Seçilen dönemin işlemlerini CSV metnine ve dosya adına dönüştürür. Tarih ve tutar biçimi
/// bölgeden bağımsızdır (2026-10-25 14:30, -12.5) ki tablolama uygulamaları sayı ve tarih olarak
/// okusun; başlıklar, işlem türü ve kategori adları ise uygulamanın dilindedir.
nonisolated struct PeriodCSV: Equatable {

    let text: String
    let filename: String

    init(
        transactions: [Transaction],
        range: DateTabs,
        interval: DateInterval,
        currencyCode: String,
        locale: Locale,
        calendar: Calendar
    ) {
        let dateFormatter = Self.posixFormatter("yyyy-MM-dd HH:mm", calendar: calendar)
        let header: [LocalizedStringResource] = ["Date", "Transaction Type", "Category", "Amount", "Currency", "Note"]

        var rows = [header.map { Self.field($0.localized(in: locale)) }]
        rows += transactions
            .filter { interval.containsHalfOpen($0.date) }
            .sorted { $0.date < $1.date }
            .map { transaction in
                [
                    dateFormatter.string(from: transaction.date),
                    Self.field(transaction.kind.title.localized(in: locale)),
                    Self.field(transaction.transactionType.details.displayName.localized(in: locale)),
                    "\(transaction.signedAmount)",
                    currencyCode,
                    Self.field(transaction.note ?? "")
                ]
            }

        text = rows.map { $0.joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
        filename = "Flow-" + Self.periodName(range: range, interval: interval, calendar: calendar)
    }

    /// Dosya adındaki dönem: "2026-10-19_2026-10-25", "2026-10" ya da "2026".
    private static func periodName(range: DateTabs, interval: DateInterval, calendar: Calendar) -> String {
        switch range {
        case .week:
            let day = posixFormatter("yyyy-MM-dd", calendar: calendar)
            return day.string(from: interval.start) + "_" + day.string(from: interval.end.addingTimeInterval(-1))
        case .month:
            return posixFormatter("yyyy-MM", calendar: calendar).string(from: interval.start)
        case .year:
            return posixFormatter("yyyy", calendar: calendar).string(from: interval.start)
        }
    }

    private static func posixFormatter(_ format: String, calendar: Calendar) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = format
        return formatter
    }

    /// Virgül, tırnak ya da satır sonu içeren metin tırnağa alınır (RFC 4180). `=`, `+`, `-`, `@`
    /// ile başlayan metin, tablolama uygulamasında formül olarak çalışmasın diye `'` ile başlatılır.
    private static func field(_ value: String) -> String {
        var value = value
        if let first = value.first, "=+-@".contains(first) {
            value = "'" + value
        }
        guard value.contains(where: { ",\"\r\n".contains($0) }) else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}
