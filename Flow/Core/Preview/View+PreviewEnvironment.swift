#if DEBUG
import SwiftUI
import SwiftData

extension View {

    /// Önizlemeler için uygulamanın ortam nesneleri ve örnek verili, bellek içi depo.
    /// Örnek veriler yalnızca DEBUG'da var olduğundan bunu kullanan `#Preview`'lar da
    /// `#if DEBUG` içinde olmalı; aksi halde Release derlemesi kırılır.
    func previewEnvironment(transactions: [Transaction] = Transaction.samples) -> some View {
        let container = ModelContainer.preview(transactions)
        let mainViewModel = MainViewModel()
        mainViewModel.loadTransactions(in: container.mainContext)

        return self
            .environment(AppRouter())
            .environment(AppState())
            .environment(ToastManager())
            .environment(mainViewModel)
            .modelContainer(container)
    }
}
#endif
