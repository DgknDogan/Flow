import Foundation

/// Aynı güne ait işlemler; listede gün başlıklı bölümler için.
nonisolated struct TransactionDayGroup: Identifiable, Equatable {
    let day: Date
    let transactions: [Transaction]

    var id: Date { day }

    /// Günleri yeniden eskiye sıralar; her günün işlemleri verilen sırayı korur.
    static func groups(from transactions: [Transaction], calendar: Calendar = .current) -> [TransactionDayGroup] {
        Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
            .map { TransactionDayGroup(day: $0.key, transactions: $0.value) }
            .sorted { $0.day > $1.day }
    }
}
