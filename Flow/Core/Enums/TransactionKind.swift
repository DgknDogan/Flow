import Foundation

nonisolated enum TransactionKind: String, Codable, Sendable, CaseIterable, TitledOption {
    // Sıra, işlem türü seçicisindeki sırayı belirler; ham değerler kayıtlı veride kullanılır.
    case expense
    case income

    var title: LocalizedStringResource {
        switch self {
        case .expense: "Expense"
        case .income: "Income"
        }
    }
}
