import Foundation
import SwiftData

/// Yeni işlem ekleme ve var olan işlemi düzenleme formunun ortak durumu.
@Observable
final class TransactionFormViewModel {

    let mode: TransactionFormMode

    var kind: TransactionKind = .expense
    var selectedExpenseCategory: ExpenseCategory = .housing
    var selectedIncomeCategory: IncomeCategory = .salary
    var selectedDate: Date = .now
    var noteText = ""
    var amount = ""
    private(set) var step: TransactionFormStep = .category

    init(mode: TransactionFormMode = .add) {
        self.mode = mode

        guard case .edit(let transaction) = mode else { return }
        kind = transaction.kind
        selectedDate = transaction.date
        noteText = transaction.note ?? ""
        // Tuş takımıyla aynı biçimde: "." ayraçlı, gereksiz sıfırsız (ör. "42.5").
        amount = NSDecimalNumber(decimal: transaction.amount.magnitude).stringValue

        switch transaction.transactionType {
        case .income(let category): selectedIncomeCategory = category
        case .expense(let category): selectedExpenseCategory = category
        }
    }

    var isEditing: Bool {
        if case .edit = mode { true } else { false }
    }

    var isLastStep: Bool {
        step.next == nil
    }

    /// Geçerli tutar (0 < tutar < 1.000.000); aksi halde `nil`.
    var finalAmount: Decimal? {
        guard let value = Decimal(string: amount), value.isValidTransactionAmount else { return nil }
        return value
    }

    func goForward() {
        if let next = step.next { step = next }
    }

    func goBack() {
        if let previous = step.previous { step = previous }
    }

    /// İşlemi ekler ya da günceller ve kaydedilmiş halini döner.
    /// Tutar geçersizse `TransactionFormError.invalidAmount`, kayıt başarısızsa depo hatası fırlatır.
    func save(in context: ModelContext) throws -> Transaction {
        guard let finalAmount else { throw TransactionFormError.invalidAmount }
        let note = noteText.isEmpty ? nil : noteText

        do {
            let entity: TransactionEntity
            switch mode {
            case .add:
                entity = TransactionEntity(amount: finalAmount, kind: kind, category: categoryRawValue, date: selectedDate, note: note)
                context.insert(entity)
            case .edit(let transaction):
                entity = try context.transactionEntity(id: transaction.id)
                entity.amount = finalAmount
                entity.category = categoryRawValue
                entity.date = selectedDate
                entity.note = note
                entity.updatedAt = .now
            }
            try context.save()
            return entity.toDomain()
        } catch {
            context.rollback()
            throw error
        }
    }

    private var categoryRawValue: String {
        switch kind {
        case .expense: selectedExpenseCategory.rawValue
        case .income: selectedIncomeCategory.rawValue
        }
    }
}
