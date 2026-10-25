#if DEBUG
import Foundation
import SwiftData

extension ModelContainer {
    /// In-memory container for previews and tests, pre-filled with the given transactions.
    /// CloudKit is off explicitly: the default `.automatic` mirrors even an in-memory store to the
    /// user's iCloud on a signed-in device, importing real data and exporting these samples.
    static func preview(_ transactions: [Transaction] = []) -> ModelContainer {
        do {
            let container = try ModelContainer(
                for: Schema(flowModels),
                configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            )
            transactions.forEach { container.mainContext.insert(TransactionEntity($0)) }
            try container.mainContext.save()
            return container
        } catch {
            fatalError("Preview container oluşturulamadı: \(error)")
        }
    }
}

extension Transaction {
    static func mock(
        id: UUID = UUID(),
        amount: Decimal = 100,
        type: TransactionKind = .expense,
        category: String = ExpenseCategory.other.rawValue,
        date: Date = .now,
        note: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) -> Transaction {
        Transaction(
            id: id,
            amount: amount,
            kind: type,
            category: category,
            date: date,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static let samples: [Transaction] = [
        .mock(amount: 120, type: .expense, category: ExpenseCategory.dining.rawValue),
        .mock(amount: 45, type: .expense, category: ExpenseCategory.transport.rawValue),
        .mock(amount: 5_000, type: .income, category: IncomeCategory.salary.rawValue)
    ]
}
#endif
