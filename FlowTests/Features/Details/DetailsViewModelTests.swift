import Testing
import Foundation
@testable import Flow

/// Dönem gezinmesi. Hesapların kendisi `PeriodReportTests`'te.
/// "Şimdi" 15 Mart 2026 öğlen (UTC).
@Suite("DetailsViewModel")
@MainActor
struct DetailsViewModelTests {

    private let calendar = TestCalendar.gmt
    private let now: Date

    init() throws {
        now = try TestCalendar.date(2026, 3, 15)
    }

    @Test func startsOnTheCurrentMonth() throws {
        let vm = makeViewModel()

        #expect(vm.dateSelection == .month)
        #expect(vm.report.interval.start == (try TestCalendar.date(2026, 3, 1, hour: 0)))
        #expect(vm.isShowingCurrentPeriod)
        #expect(!vm.canShowNextPeriod)
    }

    @Test func cannotMovePastTheCurrentPeriod() {
        let vm = makeViewModel()
        let interval = vm.report.interval

        vm.showNextPeriod()

        #expect(vm.report.interval == interval)
    }

    @Test func previousAndNextMoveOnePeriod() throws {
        let vm = makeViewModel([
            .mock(amount: 40, type: .expense, date: try TestCalendar.date(2026, 2, 10)),
            .mock(amount: 90, type: .expense, date: try TestCalendar.date(2026, 3, 10))
        ])

        vm.showPreviousPeriod()
        #expect(vm.report.interval.start == (try TestCalendar.date(2026, 2, 1, hour: 0)))
        #expect(vm.report.totalExpense == 40)
        #expect(!vm.isShowingCurrentPeriod)
        #expect(vm.canShowNextPeriod)

        vm.showNextPeriod()
        #expect(vm.report.totalExpense == 90)
        #expect(vm.isShowingCurrentPeriod)
    }

    @Test func previousCrossesYearBoundary() throws {
        let vm = makeViewModel()

        for _ in 0..<3 {
            vm.showPreviousPeriod()
        }

        #expect(vm.report.interval.start == (try TestCalendar.date(2025, 12, 1, hour: 0)))
    }

    @Test func currentPeriodJumpsBackToToday() {
        let vm = makeViewModel()
        vm.showPreviousPeriod()
        vm.showPreviousPeriod()

        vm.showCurrentPeriod()

        #expect(vm.isShowingCurrentPeriod)
    }

    /// İçinde bulunulan ayda "Year"a geçmek bu yılı açar.
    @Test func switchingRangeFromCurrentPeriodStaysCurrent() throws {
        let vm = makeViewModel()

        vm.dateSelection = .year
        #expect(vm.report.interval.start == (try TestCalendar.date(2026, 1, 1, hour: 0)))
        #expect(vm.isShowingCurrentPeriod)

        vm.dateSelection = .week
        #expect(vm.report.interval.start == (try TestCalendar.date(2026, 3, 15, hour: 0)))
        #expect(vm.isShowingCurrentPeriod)
    }

    /// Geçmiş bir aydayken "Year"a geçmek o ayın yılını açar.
    @Test func switchingRangeFromPastPeriodKeepsItsYear() throws {
        let vm = makeViewModel()
        for _ in 0..<3 {
            vm.showPreviousPeriod()
        }

        vm.dateSelection = .year

        #expect(vm.report.interval.start == (try TestCalendar.date(2025, 1, 1, hour: 0)))
        #expect(!vm.isShowingCurrentPeriod)
    }

    @Test func updatingTransactionsRefreshesReport() throws {
        let vm = makeViewModel()
        #expect(vm.report.isEmpty)

        vm.updateTransactions([.mock(amount: 12, type: .expense, date: try TestCalendar.date(2026, 3, 3))])

        #expect(vm.report.totalExpense == 12)
    }

    @Test(arguments: [(DateTabs.week, Calendar.Component.day), (.month, .day), (.year, .month)])
    func chartUnitFollowsSelection(range: DateTabs, unit: Calendar.Component) {
        let vm = makeViewModel()

        vm.dateSelection = range

        #expect(vm.chartUnit == unit)
        #expect(vm.report.range == range)
    }

    @Test func chartModelsAreIdentifiedByTheirKey() throws {
        let day = try TestCalendar.date(2026, 3, 1)
        #expect(ChartItem(date: day, amount: 5).id == day)
        #expect(CategoryShare(category: ExpenseCategory.travel, amount: 5, transactionCount: 1, share: 1).id == .travel)
    }

    private func makeViewModel(_ transactions: [Transaction] = []) -> DetailsViewModel {
        let fixedNow = now
        let vm = DetailsViewModel(calendar: calendar, now: { fixedNow })
        vm.updateTransactions(transactions)
        return vm
    }
}
