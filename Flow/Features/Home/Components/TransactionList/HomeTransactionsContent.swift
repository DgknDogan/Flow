import SwiftUI

/// Yükleme/hata durumunu, işlem listesini ya da uygun boş durumu gösterir.
struct HomeTransactionsContent: View {

    let viewState: ViewState
    let transactions: [Transaction]
    let hasAnyTransactions: Bool
    let searchText: String

    @Environment(AppRouter.self) private var router

    var body: some View {
        switch viewState {
        case .loading:
            TransactionsLoadingView()
        case .error:
            TransactionsErrorView()
                .padding(.top, 120)
        case .success:
            if !transactions.isEmpty {
                TransactionListView(transactions: transactions)
            } else if !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
                    .padding(.top, 60)
            } else if hasAnyTransactions {
                ContentUnavailableView(
                    "No Transactions on This Day",
                    systemImage: "calendar",
                    description: Text("Pick another day or add a new transaction.")
                )
                .padding(.top, 60)
            } else {
                EmptyStateView(action: openAddTransaction)
                    .padding(.top, 60)
            }
        }
    }

    private func openAddTransaction() {
        router.isAddTransactionPresented = true
    }
}
