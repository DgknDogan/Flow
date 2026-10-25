import Foundation
import SwiftData

/// CloudKit senkronizasyonu için: unique kısıt kullanılamaz ve her alanın varsayılan değeri
/// (ya da optional olması) gerekir. `id` tekilliği uygulama tarafında `UUID()` ile sağlanır.
@Model
nonisolated final class TransactionEntity {
    #Index<TransactionEntity>([\.date])

    var id: UUID = UUID()
    var amount: Decimal = 0
    var kind: String = TransactionKind.expense.rawValue
    var category: String = ExpenseCategory.other.rawValue
    var date: Date = Date.now
    var note: String?
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    init(
        id: UUID = UUID(),
        amount: Decimal,
        kind: TransactionKind,
        category: String,
        date: Date,
        note: String?,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.amount = amount
        self.kind = kind.rawValue
        self.category = category
        self.date = date
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    convenience init(_ transaction: Transaction) {
        self.init(
            id: transaction.id,
            amount: transaction.amount,
            kind: transaction.kind,
            category: transaction.category,
            date: transaction.date,
            note: transaction.note,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
    }

    func toDomain() -> Transaction {
        Transaction(
            id: id,
            amount: amount,
            kind: TransactionKind(rawValue: kind) ?? .expense,
            category: category,
            date: date,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension ModelContext {

    func transactionEntity(id: UUID) throws -> TransactionEntity {
        var descriptor = FetchDescriptor<TransactionEntity>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let entity = try fetch(descriptor).first else {
            throw PersistenceError.notFound
        }
        return entity
    }
}
