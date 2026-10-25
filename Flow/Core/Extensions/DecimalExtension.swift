import Foundation

nonisolated extension Decimal {

    /// `Double` tutarı (ör. günlük limit) ikili kayan nokta artıkları olmadan iki ondalık
    /// basamağa yuvarlayarak çevirir: `Decimal(0.1)` 0.1000000000000000512 olurdu.
    init(currencyAmount value: Double) {
        var source = Decimal(value)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &source, 2, .plain)
        self = rounded
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    var isValidTransactionAmount: Bool {
        self > 0 && self < 1_000_000
    }
}
