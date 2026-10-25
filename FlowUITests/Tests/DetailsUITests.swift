import XCTest

/// Örnek veri: bugüne tarihli Dining Out 120, Transportation 45 (gider) ve Salary 5000 (gelir).
final class DetailsUITests: FlowUITestCase {

    // MARK: - Empty

    func testEmptyDetailsOffersToAddTransaction() {
        let app = launchApp()
        let details = DetailsScreen(app: app).open()

        details.emptyStateAddButton.assertExists()
        details.emptyStateAddButton.tap()

        TransactionFormScreen(app: app).waitUntilShown()
    }

    // MARK: - Summary

    func testSummaryShowsIncomeExpensesNetAndCount() {
        let details = DetailsScreen(app: launchApp(seeded: true)).open()

        assertAppears(details.element(labelContaining: "Net Balance"))
        XCTAssertTrue(details.element(labelContaining: ", Income").label.contains("$5,000.00"))
        XCTAssertTrue(details.element(labelContaining: ", Expenses").label.contains("$165.00"))
        XCTAssertTrue(details.element(labelContaining: "Net Balance").label.contains("+$4,835.00"))
        XCTAssertTrue(details.app.element(labelContaining: ", Transactions").label.contains("3"))
    }

    func testChartShowsTotalSpentAndAverage() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()

        assertAppears(details.header("Monthly Expenses"))
        XCTAssertTrue(app.staticTexts["Total spent"].exists)
        XCTAssertTrue(app.staticTexts["$165.00"].exists, "Giderlerin toplamı 120 + 45")
        XCTAssertTrue(app.element(labelContaining: "Daily average").exists)
    }

    func testInsightsShowAverageNoSpendDaysAndSavingsRate() {
        let details = DetailsScreen(app: launchApp(seeded: true)).open()

        assertAppears(details.element(labelContaining: "Daily Average"))
        XCTAssertTrue(details.element(labelContaining: "Busiest Day").label.contains("$165.00"))
        XCTAssertTrue(details.element(labelContaining: "No-Spend Days").exists)
        // (5000 − 165) / 5000 ≈ %97.
        XCTAssertTrue(details.element(labelContaining: "Savings Rate").label.contains("97%"))
    }

    // MARK: - Categories

    func testCategoryBreakdownListsSharesAndCounts() {
        let details = DetailsScreen(app: launchApp(seeded: true)).open()

        let dining = details.categoryRow("Dining Out")
        assertAppears(dining)
        XCTAssertTrue(dining.label.contains("72.7%"))
        XCTAssertTrue(dining.label.contains("1 transaction"))
        XCTAssertTrue(details.categoryRow("Transportation").label.contains("27.3%"))
        XCTAssertTrue(details.categoryRow("Salary").label.contains("100.0%"))
    }

    func testCategoryRowOpensItsTransactions() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()

        details.categoryRow("Dining Out").tap()

        assertAppears(app.navigationBars["Dining Out"])
        XCTAssertTrue(app.buttons.firstMatch(labelContaining: "-$120.00").exists)
        XCTAssertFalse(app.buttons.firstMatch(labelContaining: "-$45.00").exists, "Başka kategorinin işlemi listelenmemeli")
    }

    func testLargestExpenseOpensEditor() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()
        assertAppears(details.header("Largest Expenses"))

        let largest = app.buttons.matching(NSPredicate(format: "label CONTAINS %@ AND NOT label CONTAINS %@", "-$120.00", "%")).firstMatch
        largest.tap()

        let form = TransactionFormScreen(app: app).waitUntilShown()
        XCTAssertTrue(form.editingBadge.label.contains("Dining Out"))
    }

    // MARK: - Periods

    func testPreviousPeriodIsEmptyAndThisMonthReturns() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()
        XCTAssertEqual(details.periodTitle.label, DetailsScreen.monthTitle(for: .now))
        XCTAssertFalse(details.nextPeriodButton.isEnabled, "Gelecek döneme gidilemez")
        XCTAssertFalse(details.currentPeriodButton.exists)

        details.previousPeriodButton.tap()

        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        assertAppears(app.staticTexts[DetailsScreen.monthTitle(for: lastMonth)])
        assertAppears(app.staticTexts["No Transactions"])
        XCTAssertTrue(details.nextPeriodButton.isEnabled)

        details.currentPeriodButton.tap()
        assertAppears(app.staticTexts[DetailsScreen.monthTitle(for: .now)])
        assertDisappears(details.currentPeriodButton)
    }

    func testRangePickerSwitchesBetweenWeekMonthAndYear() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()
        details.rangePicker.assertExists()

        details.selectRange("Year")
        assertAppears(details.header("Yearly Expenses"))
        XCTAssertEqual(details.periodTitle.label, DetailsScreen.yearTitle(for: .now))
        XCTAssertTrue(app.element(labelContaining: "Monthly average").exists)
        XCTAssertTrue(app.staticTexts["$165.00"].exists)

        details.selectRange("Week")
        assertAppears(details.header("Weekly Expenses"))
        XCTAssertTrue(app.staticTexts["$165.00"].exists)

        details.selectRange("Month")
        assertAppears(details.header("Monthly Expenses"))
    }

    // MARK: - Budget

    func testBudgetShortcutOpensBudgetSettings() {
        let app = launchApp(seeded: true)
        let details = DetailsScreen(app: app).open()

        let shortcut = details.element(labelContaining: "Set a Daily Limit")
        shortcut.tap()

        assertAppears(app.navigationBars["Budget"])
    }

    /// Ayarlardan girilen günlük limit grafikte ve bütçe bölümünde kullanılır.
    func testDailyLimitShowsBudgetProgress() {
        let app = launchApp(seeded: true)
        let settings = SettingsScreen(app: app).open()
        settings.open(.budget)
        app.textFields["Daily limit"].tap()
        app.typeText("50")
        app.navigationBars["Budget"].buttons["Save"].tap()

        let details = DetailsScreen(app: app).open()

        assertAppears(app.element(labelContaining: "Daily limit"))
        XCTAssertTrue(app.element(labelContaining: "Daily limit").label.contains("$50.00"))
        XCTAssertTrue(details.element(labelContaining: "$165.00 of").exists)
        let daysOver = details.element(labelContaining: "Days Over Limit")
        XCTAssertTrue(daysOver.label.hasSuffix("1"), "Bugünkü 165 harcama 50 limitini aşıyor: \(daysOver.label)")
    }
}
