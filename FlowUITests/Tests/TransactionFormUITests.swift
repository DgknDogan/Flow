import XCTest

final class TransactionFormUITests: FlowUITestCase {

    // MARK: - Add

    func testAddingExpenseShowsItOnHome() {
        let app = launchApp()
        let home = HomeScreen(app: app)

        home.openAddTransaction()
            .addTransaction(category: "Groceries", note: "Weekly market", amount: "42")

        assertToast("Transaction Success!", in: app)
        assertAppears(home.row(containing: "-$42.00"))
        XCTAssertTrue(home.row(containing: "Groceries").exists)
        XCTAssertTrue(home.row(containing: "Weekly market").exists)
        XCTAssertFalse(home.emptyStateTitle.exists)
    }

    func testAddingIncomeShowsPositiveAmount() {
        let app = launchApp()
        let home = HomeScreen(app: app)

        home.openAddTransaction()
            .addTransaction(kind: "Income", category: "Salary", amount: "1000")

        assertAppears(home.row(containing: "+$1,000.00"))
        XCTAssertTrue(home.row(containing: "Salary").exists)
    }

    func testIncomeTypeShowsIncomeCategories() {
        let form = HomeScreen(app: launchApp()).openAddTransaction()
        XCTAssertTrue(form.app.buttons["Groceries"].exists)

        form.selectKind("Income")

        assertAppears(form.app.buttons["Salary"])
        XCTAssertFalse(form.app.buttons["Groceries"].exists)
    }

    func testSavingWithoutAmountShowsWarningAndKeepsForm() {
        let app = launchApp()
        let form = HomeScreen(app: app).openAddTransaction()

        form.goToAmountStep()
        XCTAssertEqual(form.primaryButton.label, "Save")
        form.next()

        assertToast("Invalid Amount", in: app)
        XCTAssertTrue(form.title("Set Amount").exists, "Geçersiz tutarda form açık kalmalı")
    }

    // MARK: - Steps

    func testStepsMoveForwardAndBack() {
        let form = HomeScreen(app: launchApp()).openAddTransaction()
        XCTAssertTrue(form.title("Select Category").exists)
        XCTAssertEqual(form.primaryButton.label, "Continue")

        form.next()
        assertAppears(form.title("Transaction Details"))
        form.next()
        assertAppears(form.title("Add Note"))
        form.next()
        assertAppears(form.title("Set Amount"))

        form.backButton.tap()
        assertAppears(form.title("Add Note"))
        form.backButton.tap()
        assertAppears(form.title("Transaction Details"))
        form.backButton.tap()
        assertAppears(form.title("Select Category"))
    }

    func testCloseDismissesWithoutSaving() {
        let app = launchApp()
        let home = HomeScreen(app: app)
        let form = home.openAddTransaction()

        form.closeButton.tap()

        assertDisappears(form.primaryButton)
        XCTAssertTrue(home.emptyStateTitle.exists)
    }

    func testNoteShowsCharacterCount() {
        let form = HomeScreen(app: launchApp()).openAddTransaction()
        form.next()
        form.next()
        assertAppears(form.title("Add Note"))

        form.typeNote("Coffee")

        assertAppears(form.app.element(labelContaining: "6 of 500 characters"))
    }

    // MARK: - Keypad

    func testKeypadIgnoresLeadingZerosAndLimitsDecimals() {
        let form = HomeScreen(app: launchApp()).openAddTransaction()
        form.goToAmountStep()
        XCTAssertEqual(form.amountDisplay.label, "0")

        form.enterAmount("00")
        XCTAssertEqual(form.amountDisplay.label, "0")

        form.enterAmount(".")
        XCTAssertEqual(form.amountDisplay.label, "0.")

        form.enterAmount("555")
        XCTAssertEqual(form.amountDisplay.label, "0.55", "En fazla iki ondalık basamak")

        form.deleteDigits(1)
        XCTAssertEqual(form.amountDisplay.label, "0.5")
    }

    func testKeypadLimitsWholeDigits() {
        let form = HomeScreen(app: launchApp()).openAddTransaction()
        form.goToAmountStep()

        form.enterAmount("1234567")

        XCTAssertEqual(form.amountDisplay.label, "123456", "En fazla altı tam basamak")
    }

    // MARK: - Edit

    func testEditingUpdatesTransaction() {
        let app = launchApp(seeded: true)
        let home = HomeScreen(app: app)
        assertAppears(home.row(containing: "-$120.00"))

        let form = home.openEditor(forRowContaining: "-$120.00")
        XCTAssertTrue(form.editingBadge.exists)
        XCTAssertTrue(form.editingBadge.label.contains("Dining Out"))
        XCTAssertFalse(form.kindPicker.exists, "Düzenlemede işlem türü değiştirilemez")

        form.goToAmountStep()
        XCTAssertEqual(form.amountDisplay.label, "120", "Düzenleme mevcut tutarla başlar")
        XCTAssertEqual(form.primaryButton.label, "Update")

        form.deleteDigits(3)
        form.enterAmount("99")
        form.next()

        assertToast("Transaction Updated!", in: app)
        assertAppears(home.row(containing: "-$99.00"))
        XCTAssertFalse(home.row(containing: "-$120.00").exists)
        XCTAssertEqual(home.rows.count, 3)
    }

    func testEditingCanChangeCategory() {
        let app = launchApp(seeded: true)
        let home = HomeScreen(app: app)
        assertAppears(home.row(containing: "Transportation"))

        let form = home.openEditor(forRowContaining: "Transportation")
        form.selectCategory("Travel")
        form.goToAmountStep()
        form.next()

        assertAppears(home.row(containing: "Travel"))
        XCTAssertFalse(home.row(containing: "Transportation").exists)
    }
}
