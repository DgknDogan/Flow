import Testing
import Foundation
@testable import Flow

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    @Test func laterMonthMeansLastYear() throws {
        let now = try date(2026, 3, 15)

        #expect(HomeViewModel.year(forMonth: 12, relativeTo: now) == 2025)
        #expect(HomeViewModel.year(forMonth: 3, relativeTo: now) == 2026)
        #expect(HomeViewModel.year(forMonth: 1, relativeTo: now) == 2026)
    }

    @Test func showsOnlySelectedDay() throws {
        let vm = HomeViewModel()
        vm.selectedDate = try date(2026, 3, 15, hour: 9)
        let sameDay = Transaction.mock(date: try date(2026, 3, 15, hour: 22))
        let nextDay = Transaction.mock(date: try date(2026, 3, 16, hour: 1))

        #expect(vm.visibleTransactions(in: [sameDay, nextDay]).map(\.id) == [sameDay.id])
    }

    @Test func searchFiltersByCategoryAndNote() throws {
        let vm = HomeViewModel()
        vm.selectedDate = try date(2026, 3, 15)
        let dining = Transaction.mock(category: ExpenseCategory.dining.rawValue, date: try date(2026, 3, 15))
        let taxi = Transaction.mock(
            category: ExpenseCategory.transport.rawValue,
            date: try date(2026, 3, 15),
            note: "Airport taxi"
        )

        vm.searchText = "  taxi "
        #expect(vm.visibleTransactions(in: [dining, taxi]).map(\.id) == [taxi.id])

        vm.searchText = "dining"
        #expect(vm.visibleTransactions(in: [dining, taxi]).map(\.id) == [dining.id])
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) throws -> Date {
        try #require(Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour)))
    }

    @Test func searchTextIsTrimmed() {
        let vm = HomeViewModel()
        vm.searchText = "  taxi  "
        #expect(vm.trimmedSearchText == "taxi")
    }

    @Test func currentMonthBelongsToCurrentYear() {
        let vm = HomeViewModel()
        #expect(vm.selectedYear == Calendar.current.component(.year, from: .now))
    }

    @Test func emptySearchShowsWholeDay() throws {
        let vm = HomeViewModel()
        vm.selectedDate = try date(2026, 3, 15)
        let first = Transaction.mock(date: try date(2026, 3, 15, hour: 8))
        let second = Transaction.mock(date: try date(2026, 3, 15, hour: 20))
        vm.searchText = "   "

        #expect(vm.visibleTransactions(in: [first, second]).count == 2)
    }
}
