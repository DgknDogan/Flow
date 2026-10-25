import Foundation

nonisolated enum Currency: String, CaseIterable, TitledOption {
    case dollar = "dollarsign"
    case euro = "eurosign"
    case sterlin = "sterlingsign"
    case turkishLira = "turkishlirasign"
    case franc = "francsign"

    /// ISO 4217 kodu; tutarlar `FormatStyle` ile bu kod üzerinden biçimlendirilir.
    var code: String {
        switch self {
        case .dollar: return "USD"
        case .euro: return "EUR"
        case .sterlin: return "GBP"
        case .turkishLira: return "TRY"
        case .franc: return "CHF"
        }
    }

    var actualSymbol: String {
        switch self {
        case .dollar: return "$"
        case .euro: return "€"
        case .sterlin: return "£"
        case .turkishLira: return "₺"
        case .franc: return "CHF"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .dollar: "US Dollar"
        case .euro: "Euro"
        case .sterlin: "British Pound"
        case .turkishLira: "Turkish Lira"
        case .franc: "Swiss Franc"
        }
    }
}
