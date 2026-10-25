nonisolated enum TransactionFormError: Error {
    /// Tutar boş, sıfır ya da üst sınırın (1.000.000) üzerinde.
    case invalidAmount
}
