import SwiftUI
import SwiftData

struct TransactionsErrorView: View {

    @Environment(MainViewModel.self) private var mainVM
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't Load Transactions", systemImage: "exclamationmark.triangle")
        } description: {
            Text("An error occurred. Please try again.")
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
    }

    private func retry() {
        mainVM.loadTransactions(in: modelContext)
    }
}
