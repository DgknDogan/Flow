import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Seçilen haftanın, ayın ya da yılın özeti: toplamlar, grafik, bütçe, içgörüler,
/// kategori dağılımı ve en büyük giderler. Önceki dönemlere geri gidilebilir; gösterilen dönemin
/// işlemleri CSV olarak Dosyalar'a kaydedilebilir.
struct DetailsView: View {

    @Environment(AppRouter.self) private var router
    @Environment(MainViewModel.self) private var mainVM
    @Environment(AppState.self) private var appState
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.locale) private var locale

    @State private var viewModel = DetailsViewModel()
    @State private var transactionToEdit: Transaction?
    @State private var csvExport: PeriodCSV?
    @State private var isExporting = false
    @Namespace private var editTransition

    var body: some View {
        Group {
            if mainVM.transactions.isEmpty {
                EmptyStateView(action: openAddTransaction)
            } else {
                reportList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .localizedNavigationTitle("Details")
        .toolbar {
            if !mainVM.transactions.isEmpty {
                // Dönem değişimi animasyonlu olduğundan bu buton dışa aktarma butonunun camından
                // ayrılarak belirir ve geri dönünce onun içine karışarak kaybolur.
                if !viewModel.isShowingCurrentPeriod {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: showCurrentPeriod) {
                            Text(viewModel.dateSelection.currentPeriodTitle)
                        }
                        .accessibilityIdentifier("currentPeriodButton")
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Export CSV", systemImage: "square.and.arrow.up", action: exportCSV)
                        .disabled(!viewModel.canExport)
                        .accessibilityIdentifier("exportButton")
                }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: csvExport.map { CSVDocument(text: $0.text) },
            contentType: .commaSeparatedText,
            defaultFilename: csvExport?.filename,
            onCompletion: exportCompleted
        )
        .navigationDestination(for: CategoryRoute.self) { route in
            CategoryTransactionsView(route: route)
        }
        .editTransactionSheet(for: $transactionToEdit, zoomNamespace: editTransition, onSave: mainVM.replaceTransaction)
        .onChange(of: mainVM.transactions, initial: true) {
            viewModel.updateTransactions(mainVM.transactions)
        }
    }

    private var reportList: some View {
        @Bindable var viewModel = viewModel
        let report = viewModel.report
        let periodTitle = viewModel.periodTitle(locale: locale)

        return List {
            PeriodPickerSection(
                selection: $viewModel.dateSelection,
                title: periodTitle,
                canShowNextPeriod: viewModel.canShowNextPeriod,
                onPrevious: showPreviousPeriod,
                onNext: showNextPeriod
            )

            if report.isEmpty {
                EmptyPeriodSection(periodTitle: periodTitle)
            } else {
                PeriodSummarySection(report: report)
                ChartSectionView(report: report)
                BudgetSection(budget: report.budget(dailyLimit: appState.dailySpendingLimit))
                InsightsSection(report: report)

                if !report.expenseCategories.isEmpty {
                    CategoryBreakdownSection(
                        title: "Spending by Category",
                        shares: report.expenseCategories,
                        total: report.totalExpense,
                        showsChart: true
                    ) { category in
                        CategoryRoute(type: .expense(category), range: report.range, interval: report.interval)
                    }
                }

                if !report.incomeCategories.isEmpty {
                    CategoryBreakdownSection(
                        title: "Income by Category",
                        shares: report.incomeCategories,
                        total: report.totalIncome
                    ) { category in
                        CategoryRoute(type: .income(category), range: report.range, interval: report.interval)
                    }
                }

                if !report.largestExpenses.isEmpty {
                    LargestExpensesSection(
                        transactions: report.largestExpenses,
                        editTransition: editTransition,
                        onSelect: edit
                    )
                }
            }
        }
        .animation(AppAnimation.sectionToggle, value: report)
    }

    // MARK: - Actions

    /// Sheet `MainView`'da durduğu için sekme değiştirmeden açılır.
    private func openAddTransaction() {
        router.isAddTransactionPresented = true
    }

    private func showPreviousPeriod() {
        withAnimation(AppAnimation.selection) {
            viewModel.showPreviousPeriod()
        }
    }

    private func showNextPeriod() {
        withAnimation(AppAnimation.selection) {
            viewModel.showNextPeriod()
        }
    }

    private func showCurrentPeriod() {
        withAnimation(AppAnimation.selection) {
            viewModel.showCurrentPeriod()
        }
    }

    private func exportCSV() {
        csvExport = viewModel.csvExport(currencyCode: appState.currency.code, locale: locale)
        isExporting = true
    }

    private func exportCompleted(_ result: Result<URL, any Error>) {
        csvExport = nil
        switch result {
        case .success:
            toastManager.show(AppToasts.exportSucceeded)
        case .failure(let error as CocoaError) where error.code == .userCancelled:
            break
        case .failure:
            toastManager.show(AppToasts.exportError)
        }
    }

    private func edit(_ transaction: Transaction) {
        transactionToEdit = transaction
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DetailsView()
    }
    .previewEnvironment()
}
#endif
