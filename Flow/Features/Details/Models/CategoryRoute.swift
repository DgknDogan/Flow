import Foundation

/// Details'ten bir kategorinin seçilen dönemdeki işlemlerine gidiş.
nonisolated struct CategoryRoute: Hashable {
    let type: TransactionType
    let range: DateTabs
    let interval: DateInterval

    /// Kategorinin dönemdeki işlemleri, yeniden eskiye.
    func transactions(in transactions: [Transaction]) -> [Transaction] {
        transactions
            .filter { $0.transactionType == type && interval.containsHalfOpen($0.date) }
            .sorted { $0.date > $1.date }
    }

    func periodTitle(locale: Locale) -> String {
        range.title(for: interval, locale: locale)
    }
}
