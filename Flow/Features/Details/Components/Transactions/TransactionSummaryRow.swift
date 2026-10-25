import SwiftUI

/// Liste içindeki sade işlem satırı: kategori ikonu, başlık ve işaretli tutar.
struct TransactionSummaryRow: View {

    enum Style {
        /// Başlık kategori; altında tarih ve varsa not. Karışık kategorili listeler için.
        case category
        /// Başlık not (yoksa kategori). Tarih bölüm başlığında olduğu için tek kategorili listelerde.
        case note
    }

    let transaction: Transaction
    var style: Style = .category

    var body: some View {
        let details = transaction.transactionType.details

        IconRow(icon: details.iconName, tint: details.color, title: title(categoryName: details.displayName), subtitle: subtitle) {
            // İşaret (+/−) gelir ile gideri renkten bağımsız ayırt ettirir.
            MoneyText(transaction.signedAmount, showsSign: true)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(transaction.kind == .income ? Color.green : Color.red)
        }
    }

    private var note: String? {
        guard let note = transaction.note, !note.isEmpty else { return nil }
        return note
    }

    private func title(categoryName: LocalizedStringResource) -> Text {
        switch style {
        case .category:
            Text(categoryName)
        case .note:
            note.map { Text(verbatim: $0) } ?? Text(categoryName)
        }
    }

    private var subtitle: Text? {
        guard style == .category else { return nil }
        let date = Text(transaction.date, format: .dateTime.month(.abbreviated).day())
        guard let note else { return date }
        return Text("\(date) · \(note)")
    }
}

#if DEBUG
#Preview {
    List {
        TransactionSummaryRow(transaction: .mock(amount: 42, category: ExpenseCategory.groceries.rawValue, note: "Weekly market"))
        TransactionSummaryRow(transaction: .mock(amount: 1_000, type: .income, category: IncomeCategory.salary.rawValue), style: .note)
    }
    .environment(AppState())
}
#endif
