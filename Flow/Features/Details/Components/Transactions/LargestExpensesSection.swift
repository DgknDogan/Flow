import SwiftUI

/// Dönemin en büyük giderleri; dokununca işlem düzenleme formunda açılır.
struct LargestExpensesSection: View {

    let transactions: [Transaction]
    /// Satırlardan büyüyerek açılan düzenleme sheet'iyle aynı namespace.
    let editTransition: Namespace.ID
    let onSelect: (Transaction) -> Void

    var body: some View {
        Section("Largest Expenses") {
            ForEach(transactions) { transaction in
                Button {
                    onSelect(transaction)
                } label: {
                    TransactionSummaryRow(transaction: transaction)
                }
                .buttonStyle(.plain)
                .matchedTransitionSource(id: transaction.id, in: editTransition)
            }
        }
    }
}
