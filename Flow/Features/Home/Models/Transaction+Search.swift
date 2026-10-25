import Foundation

nonisolated extension Transaction {

    /// Kategori adında (ekranda görünen dilde) ya da notta; büyük/küçük harf ve aksan duyarsız arar.
    func matches(_ query: String, locale: Locale = .current) -> Bool {
        transactionType.details.displayName.localized(in: locale).localizedStandardContains(query)
            || (note?.localizedStandardContains(query) ?? false)
    }
}
