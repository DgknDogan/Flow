/// İşlem formunun adımları; sıra `allCases` sırasıdır.
nonisolated enum TransactionFormStep: SequentialCase {
    case category
    case date
    case note
    case amount
}
