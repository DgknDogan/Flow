import Testing
import Foundation
@testable import Flow

@Suite("Transaction")
struct TransactionTests {

    @Test func transactionTypeReflectsKindAndCategory() {
        let expense = Transaction.mock(type: .expense, category: ExpenseCategory.dining.rawValue)
        let income = Transaction.mock(type: .income, category: IncomeCategory.salary.rawValue)

        #expect(expense.transactionType == .expense(.dining))
        #expect(income.transactionType == .income(.salary))
    }

    @Test func unknownCategoryFallsBackToOther() {
        let transaction = Transaction.mock(type: .expense, category: "unknown")
        #expect(transaction.transactionType == .expense(.other))
    }

    @Test func signedAmountIsNegativeForExpenses() {
        #expect(Transaction.mock(amount: 12, type: .expense).signedAmount == -12)
        #expect(Transaction.mock(amount: 12, type: .income).signedAmount == 12)
    }

    /// Ham değerler kayıtlı verinin anahtarıdır; değişirse eski işlemler `.other`'a düşer.
    @Test func categoryRawValuesStayStable() {
        #expect(ExpenseCategory.dining.rawValue == "Dining Out")
        #expect(ExpenseCategory.transport.rawValue == "Transportation")
        #expect(IncomeCategory.rental.rawValue == "Rental Income")
        #expect(TransactionKind.expense.rawValue == "expense")
    }

    @Test(arguments: ["dining", "DINING", "lunch"])
    func searchMatchesCategoryOrNote(query: String) {
        let transaction = Transaction.mock(category: ExpenseCategory.dining.rawValue, note: "Lunch with a friend")
        #expect(transaction.matches(query))
    }

    @Test func searchIgnoresDiacritics() {
        #expect(Transaction.mock(note: "Kahve ve börek").matches("borek"))
    }

    @Test func searchRejectsUnrelatedText() {
        #expect(!Transaction.mock(category: ExpenseCategory.dining.rawValue).matches("salary"))
    }
}
