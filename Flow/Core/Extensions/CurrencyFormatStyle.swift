import Foundation

// Tutarları seçili para birimiyle, cihazın bölge ayarına göre biçimlendirir
// (ör. en_US: "$1,234.50", tr_TR: "₺1.234,50"). `.narrow` tek karakterli sembolü tercih eder.

nonisolated extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    static func currency(_ currency: Currency) -> Self {
        .currency(code: currency.code).presentation(.narrow)
    }
}

nonisolated extension FormatStyle where Self == FloatingPointFormatStyle<Double>.Currency {
    static func currency(_ currency: Currency) -> Self {
        .currency(code: currency.code).presentation(.narrow)
    }
}
