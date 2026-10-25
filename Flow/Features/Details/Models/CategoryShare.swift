import Foundation

/// Bir kategorinin dönem içindeki toplamı, işlem sayısı ve tüm toplamdaki payı.
nonisolated struct CategoryShare<Category: CategoryProtocol>: Identifiable, Equatable {
    let category: Category
    let amount: Decimal
    let transactionCount: Int
    /// 0...1 arası pay; yüzde biçimlendirmesi görünümde yapılır.
    let share: Double

    var id: Category { category }
}

/// Kategori başına biriken tutar ve işlem sayısı.
nonisolated struct CategoryTotal: Equatable {
    var amount: Decimal = 0
    var count = 0

    mutating func add(_ amount: Decimal) {
        self.amount += amount
        count += 1
    }
}

nonisolated extension CategoryShare {
    /// Toplamlardan payları üretir: büyükten küçüğe, eşit tutarlarda ham değere göre sabit sırada.
    static func shares(from totals: [Category: CategoryTotal]) -> [CategoryShare] {
        let total = totals.values.reduce(Decimal.zero) { $0 + $1.amount }
        guard total > 0 else { return [] }

        return totals
            .sorted { lhs, rhs in
                lhs.value.amount == rhs.value.amount
                    ? lhs.key.rawValue < rhs.key.rawValue
                    : lhs.value.amount > rhs.value.amount
            }
            .map { category, categoryTotal in
                CategoryShare(
                    category: category,
                    amount: categoryTotal.amount,
                    transactionCount: categoryTotal.count,
                    share: (categoryTotal.amount / total).doubleValue
                )
            }
    }
}
