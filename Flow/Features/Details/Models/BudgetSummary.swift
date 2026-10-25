import Foundation

/// Günlük limite göre dönem bütçesinin durumu.
nonisolated struct BudgetSummary: Equatable {
    let dailyLimit: Decimal
    /// Dönem bütçesi: günlük limit × dönemdeki gün sayısı.
    let limit: Decimal
    let spent: Decimal
    /// Gideri günlük limiti aşan gün sayısı.
    let daysOverLimit: Int
    /// İçinde bulunulan dönemde, bugün dahil kalan günlere düşen harcanabilir tutar;
    /// geçmiş dönemlerde ya da bütçe aşıldıysa `nil`.
    let dailyAllowance: Decimal?

    var remaining: Decimal {
        limit - spent
    }

    var isOverBudget: Bool {
        spent > limit
    }

    /// Harcanan / bütçe; 1'i geçebilir.
    var progress: Double {
        limit > 0 ? (spent / limit).doubleValue : 0
    }
}
