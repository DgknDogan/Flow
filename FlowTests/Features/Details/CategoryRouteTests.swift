import Testing
import Foundation
@testable import Flow

@Suite("CategoryRoute and day groups")
struct CategoryRouteTests {

    private let calendar = TestCalendar.gmt

    @Test func routeListsOnlyThatCategoryInThePeriodNewestFirst() throws {
        let march = DateTabs.month.interval(containing: try TestCalendar.date(2026, 3, 15), calendar: calendar)
        let route = CategoryRoute(type: .expense(.dining), range: .month, interval: march)
        let early = Transaction.mock(amount: 10, type: .expense, category: ExpenseCategory.dining.rawValue, date: try TestCalendar.date(2026, 3, 2))
        let late = Transaction.mock(amount: 20, type: .expense, category: ExpenseCategory.dining.rawValue, date: try TestCalendar.date(2026, 3, 20))
        let otherCategory = Transaction.mock(amount: 30, type: .expense, category: ExpenseCategory.travel.rawValue, date: try TestCalendar.date(2026, 3, 5))
        let otherMonth = Transaction.mock(amount: 40, type: .expense, category: ExpenseCategory.dining.rawValue, date: try TestCalendar.date(2026, 4, 1))

        let result = route.transactions(in: [early, otherCategory, late, otherMonth])

        #expect(result.map(\.id) == [late.id, early.id])
    }

    /// Bilinmeyen kategori anahtarları `.other`'a düştüğü için "Other" sayfasında görünür.
    @Test func unknownCategoryBelongsToOther() throws {
        let march = DateTabs.month.interval(containing: try TestCalendar.date(2026, 3, 15), calendar: calendar)
        let route = CategoryRoute(type: .income(.other), range: .month, interval: march)
        let legacy = Transaction.mock(amount: 5, type: .income, category: "Lottery", date: try TestCalendar.date(2026, 3, 3))

        #expect(route.transactions(in: [legacy]).count == 1)
    }

    @Test func groupsByDayNewestDayFirst() throws {
        let morning = Transaction.mock(amount: 1, date: try TestCalendar.date(2026, 3, 2, hour: 8))
        let evening = Transaction.mock(amount: 2, date: try TestCalendar.date(2026, 3, 2, hour: 20))
        let later = Transaction.mock(amount: 3, date: try TestCalendar.date(2026, 3, 5))

        let groups = TransactionDayGroup.groups(from: [evening, later, morning], calendar: calendar)

        #expect(groups.map(\.day) == [try TestCalendar.date(2026, 3, 5, hour: 0), try TestCalendar.date(2026, 3, 2, hour: 0)])
        #expect(groups[1].transactions.map(\.id) == [evening.id, morning.id], "Gün içindeki sıra korunur")
    }

    @Test func noTransactionsMeansNoGroups() {
        #expect(TransactionDayGroup.groups(from: []).isEmpty)
    }
}
