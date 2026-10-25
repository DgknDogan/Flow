import SwiftUI

/// Yeni işlem formunu sheet olarak açar; kayıttan sonra "eklendi" toast'ı sheet kapanınca gösterilir.
struct AddTransactionSheet: ViewModifier {

    @Binding var isPresented: Bool
    let onSave: (Transaction) -> Void

    @Environment(ToastManager.self) private var toastManager

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: toastManager.showPendingToast) {
                DynamicSheet {
                    TransactionFormView(onSave: transactionSaved)
                }
            }
    }

    private func transactionSaved(_ transaction: Transaction) {
        onSave(transaction)
        toastManager.showAfterDismiss(AppToasts.transactionAdded)
    }
}
