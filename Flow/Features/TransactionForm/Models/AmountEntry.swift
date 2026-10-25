import Foundation

/// Tuş takımı girişini tutar metnine uygular. Metin her zaman "." ayraçlı tutulur ki
/// `Decimal(string:)` ile okunabilsin; kullanıcıya gösterirken yerel ayraç kullanılır.
nonisolated enum AmountEntry {

    /// En fazla 999999,99: `Decimal.isValidTransactionAmount` üst sınırıyla uyumlu.
    static let maxIntegerDigits = 6
    static let maxFractionDigits = 2

    static func applying(_ key: KeypadKey, to amount: String) -> String {
        switch key {
        case .delete:
            return String(amount.dropLast())
        case .decimalSeparator:
            guard !amount.contains(".") else { return amount }
            return amount.isEmpty ? "0." : amount + "."
        case .digit(let digit):
            return appending(digit, to: amount)
        }
    }

    static func displayText(for amount: String, locale: Locale = .current) -> String {
        let text = amount.isEmpty ? "0" : amount
        return text.replacing(".", with: locale.decimalSeparator ?? ".")
    }

    private static func appending(_ digit: Int, to amount: String) -> String {
        // Baştaki sıfır tutulmaz: "0" + 5 → "5".
        if amount.isEmpty || amount == "0" {
            return digit == 0 ? amount : String(digit)
        }

        if let separator = amount.firstIndex(of: ".") {
            let fraction = amount[amount.index(after: separator)...]
            guard fraction.count < maxFractionDigits else { return amount }
        } else {
            guard amount.count < maxIntegerDigits else { return amount }
        }
        return amount + String(digit)
    }
}
