/// Form yeni işlem mi ekliyor, yoksa var olanı mı düzenliyor.
nonisolated enum TransactionFormMode {
    case add
    case edit(Transaction)
}
