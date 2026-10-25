import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(MainViewModel.self) private var mainVM
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale

    @State private var viewModel = HomeViewModel()
    @State private var isSearchActive = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        let transactions = viewModel.visibleTransactions(in: mainVM.transactions, locale: locale)

        ExpandableNavigationBar(
            title: "Home",
            itemCount: transactions.count,
            searchText: $viewModel.searchText,
            selectedDate: $viewModel.selectedDate,
            selectedMonth: $viewModel.selectedMonth,
            selectedYear: viewModel.selectedYear,
            searchFieldFocus: $isSearchFieldFocused
        ) {
            HomeTransactionsContent(
                viewState: mainVM.viewState,
                transactions: transactions,
                hasAnyTransactions: !mainVM.transactions.isEmpty,
                searchText: viewModel.trimmedSearchText
            )
        }
        .onChange(of: isSearchFieldFocused) { _, isFocused in
            withAnimation(AppAnimation.search) {
                isSearchActive = isFocused
            }
        }
        .animation(AppAnimation.sectionToggle, value: transactions.map(\.id))
        .overlay(alignment: .topTrailing) {
            HomeActionButtons(
                isSearching: isSearchActive,
                selectedMonth: $viewModel.selectedMonth,
                onPrimaryAction: handlePrimaryAction
            )
            .padding(.top, 20)
            .padding(.horizontal, 20)
        }
        .task {
            if mainVM.transactions.isEmpty {
                mainVM.loadTransactions(in: modelContext)
            }
        }
    }

    /// Arama açıksa kapatır, değilse işlem ekleme sheet'ini açar.
    private func handlePrimaryAction() {
        if isSearchFieldFocused {
            withAnimation(AppAnimation.search) {
                isSearchFieldFocused = false
            }
        } else {
            router.isAddTransactionPresented = true
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView()
    }
    .previewEnvironment()
}
#endif
