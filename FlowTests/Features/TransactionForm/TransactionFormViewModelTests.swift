import Testing
import Foundation
import SwiftData
@testable import Flow

@Suite("TransactionFormViewModel")
@MainActor
struct TransactionFormViewModelTests {

    // MARK: - Add

    @Test func addRejectsZeroAmount() throws {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel()
        vm.amount = "0"

        #expect(throws: TransactionFormError.invalidAmount) {
            try vm.save(in: container.mainContext)
        }
        #expect(try container.mainContext.fetchCount(FetchDescriptor<TransactionEntity>()) == 0)
    }

    @Test(arguments: ["", "abc", "1000000"])
    func invalidAmountsHaveNoFinalAmount(amount: String) {
        let vm = TransactionFormViewModel()
        vm.amount = amount
        #expect(vm.finalAmount == nil)
    }

    @Test func addPersistsExpense() throws {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel()
        vm.kind = .expense
        vm.selectedExpenseCategory = .dining
        vm.amount = "25.50"
        vm.noteText = "lunch"

        let result = try vm.save(in: container.mainContext)

        #expect(result.kind == .expense)
        #expect(result.category == ExpenseCategory.dining.rawValue)
        #expect(result.amount == Decimal(string: "25.50"))
        #expect(result.note == "lunch")
        let stored = try container.mainContext.transactionEntity(id: result.id).toDomain()
        #expect(stored == result)
    }

    @Test func addUsesIncomeCategoryForIncome() throws {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel()
        vm.kind = .income
        vm.selectedIncomeCategory = .bonus
        vm.amount = "300"

        let result = try vm.save(in: container.mainContext)

        #expect(result.kind == .income)
        #expect(result.category == IncomeCategory.bonus.rawValue)
    }

    @Test func emptyNoteIsStoredAsNil() throws {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel()
        vm.amount = "5"

        let result = try vm.save(in: container.mainContext)

        #expect(result.note == nil)
    }

    // MARK: - Edit

    @Test func editPrefillsFields() throws {
        let transaction = Transaction.mock(
            amount: try #require(Decimal(string: "42.50")),
            type: .income,
            category: IncomeCategory.salary.rawValue,
            note: "march"
        )

        let vm = TransactionFormViewModel(mode: .edit(transaction))

        #expect(vm.isEditing)
        #expect(vm.amount == "42.5")
        #expect(vm.kind == .income)
        #expect(vm.selectedIncomeCategory == .salary)
        #expect(vm.noteText == "march")
        #expect(vm.selectedDate == transaction.date)
    }

    @Test func editPersistsChanges() throws {
        let initial = Transaction.mock(amount: 10, type: .expense, category: ExpenseCategory.other.rawValue)
        let container = ModelContainer.preview([initial])
        let vm = TransactionFormViewModel(mode: .edit(initial))
        vm.amount = "42.5"
        vm.selectedExpenseCategory = .travel

        let result = try vm.save(in: container.mainContext)

        #expect(result.id == initial.id)
        #expect(result.amount == Decimal(string: "42.5"))
        #expect(result.category == ExpenseCategory.travel.rawValue)
        #expect(result.updatedAt >= initial.updatedAt)
    }

    @Test func editMissingTransactionThrowsNotFound() {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel(mode: .edit(.mock()))
        vm.amount = "5"

        #expect(throws: PersistenceError.notFound) {
            try vm.save(in: container.mainContext)
        }
    }

    // MARK: - Steps

    @Test func stepsMoveWithinBounds() {
        let vm = TransactionFormViewModel()
        #expect(vm.step == .category)

        vm.goBack()
        #expect(vm.step == .category)

        vm.goForward()
        vm.goForward()
        vm.goForward()
        #expect(vm.step == .amount)
        #expect(vm.isLastStep)

        vm.goForward()
        #expect(vm.step == .amount)

        vm.goBack()
        #expect(vm.step == .note)
    }

    // MARK: - Defaults

    @Test func newFormStartsInAddModeWithDefaults() {
        let vm = TransactionFormViewModel()

        #expect(!vm.isEditing)
        #expect(vm.kind == .expense)
        #expect(vm.selectedExpenseCategory == .housing)
        #expect(vm.selectedIncomeCategory == .salary)
        #expect(vm.amount.isEmpty)
        #expect(vm.noteText.isEmpty)
        #expect(!vm.isLastStep)
    }

    @Test func addKeepsTheSelectedDate() throws {
        let container = ModelContainer.preview()
        let vm = TransactionFormViewModel()
        let date = Date(timeIntervalSince1970: 1_750_000_000)
        vm.selectedDate = date
        vm.amount = "8"

        let result = try vm.save(in: container.mainContext)

        #expect(result.date == date)
    }

    @Test func editCanClearTheNoteAndMoveTheDate() throws {
        let initial = Transaction.mock(date: Date(timeIntervalSince1970: 1_000), note: "old note")
        let container = ModelContainer.preview([initial])
        let vm = TransactionFormViewModel(mode: .edit(initial))
        let newDate = Date(timeIntervalSince1970: 2_000)
        vm.noteText = ""
        vm.selectedDate = newDate

        let result = try vm.save(in: container.mainContext)

        #expect(result.note == nil)
        #expect(result.date == newDate)
        #expect(result.createdAt == initial.createdAt)
    }

    @Test func editStoresAmountWithoutSign() throws {
        let initial = Transaction.mock(amount: 10, type: .expense)
        let vm = TransactionFormViewModel(mode: .edit(initial))

        #expect(vm.amount == "10")
        #expect(vm.finalAmount == 10)
    }
}
