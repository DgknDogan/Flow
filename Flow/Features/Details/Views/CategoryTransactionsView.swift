import SwiftUI
import SwiftData

/// Bir kategorinin seçilen dönemdeki işlemleri, günlere göre gruplu.
/// Dokununca düzenleme formu açılır, sola kaydırınca silinir.
struct CategoryTransactionsView: View {

    let route: CategoryRoute

    @Environment(MainViewModel.self) private var mainVM
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale

    @State private var transactionToEdit: Transaction?
    @Namespace private var editTransition

    var body: some View {
        let transactions = route.transactions(in: mainVM.transactions)
        let details = route.type.details
        let periodTitle = route.periodTitle(locale: locale)

        List {
            if transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: details.iconName,
                    description: Text("There are no transactions in this category for \(periodTitle).")
                )
                .listRowBackground(Color.clear)
            } else {
                CategorySummarySection(type: route.type, transactions: transactions)

                ForEach(TransactionDayGroup.groups(from: transactions)) { group in
                    Section {
                        ForEach(group.transactions) { transaction in
                            row(for: transaction)
                        }
                    } header: {
                        Text(group.day, format: .dateTime.weekday(.wide).month(.wide).day())
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .localizedNavigationTitle(details.displayName)
        .navigationSubtitle(periodTitle)
        .navigationBarTitleDisplayMode(.inline)
        .animation(AppAnimation.sectionToggle, value: transactions)
        .editTransactionSheet(for: $transactionToEdit, zoomNamespace: editTransition, onSave: mainVM.replaceTransaction)
    }

    private func row(for transaction: Transaction) -> some View {
        Button {
            transactionToEdit = transaction
        } label: {
            TransactionSummaryRow(transaction: transaction, style: .note)
        }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: transaction.id, in: editTransition)
        .swipeActions {
            Button("Delete", systemImage: "trash", role: .destructive) {
                delete(transaction)
            }
        }
    }

    private func delete(_ transaction: Transaction) {
        do {
            try mainVM.deleteTransaction(transaction, in: modelContext)
        } catch {
            toastManager.show(AppToasts.transactionDeleteError)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CategoryTransactionsView(
            route: CategoryRoute(
                type: .expense(.dining),
                range: .month,
                interval: DateTabs.month.interval(containing: .now, calendar: .current)
            )
        )
    }
    .previewEnvironment()
}
#endif
