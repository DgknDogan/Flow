import SwiftUI

struct TransactionListView: View {

    let transactions: [Transaction]

    @Environment(MainViewModel.self) private var mainVM

    @State private var transactionToEdit: Transaction?
    @Namespace private var editTransition

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions")
                .font(.headline)
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(transactions) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        showsDivider: transaction.id != transactions.last?.id
                    ) {
                        transactionToEdit = transaction
                    }
                    .matchedTransitionSource(id: transaction.id, in: editTransition)
                }
            }
            .clipShape(.rect(cornerRadius: AppRadius.card))
        }
        .editTransactionSheet(for: $transactionToEdit, zoomNamespace: editTransition, onSave: mainVM.replaceTransaction)
    }
}
