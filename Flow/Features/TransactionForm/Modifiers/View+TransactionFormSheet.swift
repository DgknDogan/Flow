import SwiftUI

extension View {

    /// Yeni işlem ekleme formunu sheet olarak bağlar.
    func addTransactionSheet(
        isPresented: Binding<Bool>,
        onSave: @escaping (Transaction) -> Void
    ) -> some View {
        modifier(AddTransactionSheet(isPresented: isPresented, onSave: onSave))
    }

    /// `transaction` dolunca o işlemi düzenleme formunda açar.
    /// - Parameter zoomNamespace: Satırlardaki `matchedTransitionSource` ile aynı namespace.
    func editTransactionSheet(
        for transaction: Binding<Transaction?>,
        zoomNamespace: Namespace.ID,
        onSave: @escaping (Transaction) -> Void
    ) -> some View {
        modifier(EditTransactionSheet(transaction: transaction, zoomNamespace: zoomNamespace, onSave: onSave))
    }
}
