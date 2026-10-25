import Testing
import Foundation
import SwiftData
@testable import Flow

@Suite("TransactionEntity")
@MainActor
struct TransactionEntityTests {

    @Test func entityRoundTripsAllFields() throws {
        let original = Transaction.mock(
            amount: try #require(Decimal(string: "42.50")),
            type: .income,
            category: IncomeCategory.salary.rawValue,
            date: Date(timeIntervalSince1970: 1_700_000_000),
            note: "lunch"
        )
        let container = ModelContainer.preview([original])

        let fetched = try container.mainContext.transactionEntity(id: original.id).toDomain()

        #expect(fetched == original)
    }

    @Test func missingIdThrowsNotFound() {
        let container = ModelContainer.preview()

        #expect(throws: PersistenceError.notFound) {
            try container.mainContext.transactionEntity(id: UUID())
        }
    }
}
