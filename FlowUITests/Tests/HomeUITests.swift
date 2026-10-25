import XCTest

final class HomeUITests: FlowUITestCase {

    // MARK: - Empty state

    func testEmptyStateIsShownWithoutTransactions() {
        let home = HomeScreen(app: launchApp())

        assertAppears(home.emptyStateTitle)
        XCTAssertTrue(home.emptyStateAddButton.exists)
        XCTAssertEqual(home.rows.count, 0)
    }

    func testEmptyStateButtonOpensAddForm() {
        let app = launchApp()
        let home = HomeScreen(app: app)
        assertAppears(home.emptyStateAddButton)

        home.emptyStateAddButton.tap()

        let form = TransactionFormScreen(app: app).waitUntilShown()
        XCTAssertTrue(form.title("Select Category").exists)
    }

    // MARK: - List

    func testSeededTransactionsAreListedForToday() {
        let home = HomeScreen(app: launchApp(seeded: true))

        assertAppears(home.row(containing: "Dining Out"))
        XCTAssertEqual(home.rows.count, 3)
        XCTAssertTrue(home.row(containing: "-$120.00").exists)
        XCTAssertTrue(home.row(containing: "-$45.00").exists)
        XCTAssertTrue(home.row(containing: "+$5,000.00").exists)
    }

    func testAnotherDayWithoutTransactionsShowsDayEmptyState() {
        let home = HomeScreen(app: launchApp(seeded: true))
        assertAppears(home.row(containing: "Dining Out"))

        home.selectDay(Self.neighbourDayInThisMonth)
        assertAppears(home.emptyDayTitle)
        XCTAssertEqual(home.rows.count, 0)

        home.selectDay(.now)
        assertAppears(home.row(containing: "Dining Out"))
        XCTAssertEqual(home.rows.count, 3)
    }

    func testChoosingAnotherMonthShowsThatMonthsDays() {
        let home = HomeScreen(app: launchApp(seeded: true))
        assertAppears(home.row(containing: "Dining Out"))

        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        home.selectMonth(of: lastMonth)

        assertAppears(home.emptyDayTitle)
        XCTAssertEqual(home.rows.count, 0)
    }

    // MARK: - Search

    func testSearchFiltersByCategoryName() {
        let home = HomeScreen(app: launchApp(seeded: true))
        assertAppears(home.row(containing: "Dining Out"))

        home.search("dining")

        assertDisappears(home.row(containing: "Salary"))
        XCTAssertEqual(home.rows.count, 1)
        XCTAssertTrue(home.row(containing: "Dining Out").exists)
    }

    func testSearchWithoutMatchesShowsNoResults() {
        let home = HomeScreen(app: launchApp(seeded: true))
        assertAppears(home.row(containing: "Dining Out"))

        home.search("zzz")

        assertAppears(home.noSearchResults)
        XCTAssertEqual(home.rows.count, 0)
    }

    func testSearchSwapsAddButtonForCloseSearch() {
        let home = HomeScreen(app: launchApp(seeded: true))
        XCTAssertEqual(home.primaryButton.label, "Add Transaction")

        home.search("d")
        assertAppears(home.app.buttons["Close Search"])
        XCTAssertFalse(home.monthPickerButton.exists, "Arama açıkken ay seçici gizlenmeli")

        home.primaryButton.tap()
        assertAppears(home.app.buttons["Add Transaction"])
        XCTAssertTrue(home.monthPickerButton.waitForExistence(timeout: Self.timeout))
    }

    // MARK: - Delete

    func testSwipeToDeleteRemovesTransaction() {
        let home = HomeScreen(app: launchApp(seeded: true))
        assertAppears(home.row(containing: "Transportation"))

        home.deleteRow(containing: "Transportation")

        assertDisappears(home.row(containing: "Transportation"))
        XCTAssertEqual(home.rows.count, 2)
    }

    // MARK: - Tabs

    func testTabsSwitchBetweenScreens() {
        let app = launchApp()

        app.tab("Details").tap(until: app.navigationBars["Details"])
        app.tab("Settings").tap(until: app.navigationBars["Settings"])
        app.tab("Home").tap(until: HomeScreen(app: app).primaryButton)
    }

    // MARK: - Helpers

    /// Bugünle aynı aydaki komşu gün (ayın 1'iyse 2'si, değilse dünü); seçici bugünü
    /// ortaladığı için ekranda görünür.
    private static var neighbourDayInThisMonth: Date {
        let calendar = Calendar.current
        let offset = calendar.component(.day, from: .now) == 1 ? 1 : -1
        return calendar.date(byAdding: .day, value: offset, to: .now)!
    }
}
