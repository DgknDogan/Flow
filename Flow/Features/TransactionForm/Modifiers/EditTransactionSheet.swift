import SwiftUI

/// Seçilen işlemi düzenleme formunda açar; satırdan büyüyerek (zoom) gelir.
/// Kayıttan sonra "güncellendi" toast'ı sheet kapanınca gösterilir.
struct EditTransactionSheet: ViewModifier {

    @Binding var transaction: Transaction?
    let zoomNamespace: Namespace.ID
    let onSave: (Transaction) -> Void

    @Environment(ToastManager.self) private var toastManager

    func body(content: Content) -> some View {
        content
            .sheet(item: $transaction, onDismiss: toastManager.showPendingToast) { transaction in
                DynamicSheet {
                    TransactionFormView(mode: .edit(transaction), onSave: transactionSaved)
                        .navigationTransition(.zoom(sourceID: transaction.id, in: zoomNamespace))
                }
                .id(transaction)
            }
    }

    private func transactionSaved(_ transaction: Transaction) {
        onSave(transaction)
        toastManager.showAfterDismiss(AppToasts.transactionUpdated)
    }
}
