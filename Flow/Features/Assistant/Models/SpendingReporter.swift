import Foundation
import SwiftData

/// Asistan aracının kullanıcının işlemlerine ulaştığı tek yol. Bütün işlemler bağlama sığmayacağı
/// için model yalnızca istediği dönemin özetini alır. Çağrı arka planda çalıştığından kendi
/// `ModelContext`'ini açar.
nonisolated struct SpendingReporter {

    let container: ModelContainer
    let currency: Currency
    let locale: Locale
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    func report(period: SpendingPeriod, startDate: String?, endDate: String?, category: String?) throws -> String {
        let dateStyle = Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day()
        guard let interval = period.interval(
            now: now(),
            calendar: calendar,
            customStart: startDate.flatMap { try? dateStyle.parse($0) },
            customEnd: endDate.flatMap { try? dateStyle.parse($0) }
        ) else {
            return "Invalid period: a custom period needs startDate and endDate in yyyy-MM-dd format."
        }

        let previousInterval = period.previousInterval(of: interval, calendar: calendar)
        let filter = category.flatMap { SpendingSummary.categoryFilter(matching: $0, locale: locale) }

        let summary = SpendingSummary(
            transactions: try fetchTransactions(from: previousInterval?.start ?? interval.start, to: interval.end),
            interval: interval,
            previousInterval: previousInterval,
            filter: filter
        )
        return summary.report(currency: currency, locale: locale, calendar: calendar)
    }

    private func fetchTransactions(from start: Date, to end: Date) throws -> [Transaction] {
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try context.fetch(descriptor).map { $0.toDomain() }
    }
}
