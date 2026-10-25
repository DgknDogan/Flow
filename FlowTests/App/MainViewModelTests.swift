import Testing
import Foundation
import SwiftData
@testable import Flow

@Suite("MainViewModel")
@MainActor
struct MainViewModelTests {

    @Test func loadTransactionsPopulatesAndSortsDescending() {
        let older = Transaction.mock(date: Date(timeIntervalSince1970: 1_000))
        let newer = Transaction.mock(date: Date(timeIntervalSince1970: 2_000))
        let container = ModelContainer.preview([older, newer])

        let vm = MainViewModel()
        vm.loadTransactions(in: container.mainContext)

        #expect(vm.viewState == .success)
        #expect(vm.transactions.map(\.id) == [newer.id, older.id])
    }

    @Test func deleteTransactionRemovesFromStoreAndList() throws {
        let transaction = Transaction.mock()
        let container = ModelContainer.preview([transaction])
        let vm = MainViewModel()
        vm.loadTransactions(in: container.mainContext)

        try vm.deleteTransaction(transaction, in: container.mainContext)

        #expect(vm.transactions.isEmpty)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<TransactionEntity>()) == 0)
    }

    @Test func deleteTransactionRemovesLocallyEvenOnNotFound() throws {
        let container = ModelContainer.preview()
        let vm = MainViewModel()
        let unknown = Transaction.mock()
        vm.appendTransaction(unknown)

        try vm.deleteTransaction(unknown, in: container.mainContext)

        #expect(vm.transactions.isEmpty)
    }

    @Test func appendTransactionInsertsAtTop() {
        let container = ModelContainer.preview([.mock()])
        let vm = MainViewModel()
        vm.loadTransactions(in: container.mainContext)

        let new = Transaction.mock()
        vm.appendTransaction(new)

        #expect(vm.transactions.first?.id == new.id)
        #expect(vm.transactions.count == 2)
    }

    @Test func replaceTransactionUpdatesExistingById() {
        let initial = Transaction.mock(amount: 10)
        let container = ModelContainer.preview([initial])
        let vm = MainViewModel()
        vm.loadTransactions(in: container.mainContext)

        vm.replaceTransaction(.mock(id: initial.id, amount: 99))

        #expect(vm.transactions.count == 1)
        #expect(vm.transactions.first?.amount == 99)
    }

    @Test func replaceTransactionInsertsWhenIdNotFound() {
        let vm = MainViewModel()

        let unknown = Transaction.mock()
        vm.replaceTransaction(unknown)

        #expect(vm.transactions.count == 1)
        #expect(vm.transactions.first?.id == unknown.id)
    }
}
