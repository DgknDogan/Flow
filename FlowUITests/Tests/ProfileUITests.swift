import XCTest

final class ProfileUITests: FlowUITestCase {

    func testNewProfileShowsPlaceholders() {
        let app = launchApp()
        let profile = SettingsScreen(app: app).open().openProfile()

        XCTAssertTrue(app.staticTexts["Your Name"].exists)
        XCTAssertTrue(profile.nameRow.label.contains("Add"))
        XCTAssertTrue(app.element(labelContaining: "Member since").exists)
    }

    func testEditingNameUpdatesProfileAndSettings() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        let profile = settings.openProfile()

        profile.editName(to: "Alex Morgan")

        assertToast("Profile Updated", in: app)
        assertAppears(app.staticTexts["Alex Morgan"])
        XCTAssertTrue(profile.nameRow.label.contains("Alex Morgan"))
        // Toast geri butonunun üstünde durabildiği için `goBack` dokunuşu gerekirse tekrarlar.
        settings.goBack()
        XCTAssertTrue(settings.profileRow.label.contains("Alex Morgan"))
    }

    func testCancellingNameEditKeepsOldName() {
        let app = launchApp()
        let profile = SettingsScreen(app: app).open().openProfile()

        profile.editName(to: "Bob", confirmWith: "Cancel")

        assertDisappears(profile.nameAlert)
        XCTAssertTrue(app.staticTexts["Your Name"].exists)
        XCTAssertFalse(app.staticTexts["Bob"].exists)
    }

    func testStatsSummarizeTransactions() {
        let app = launchApp(seeded: true)
        SettingsScreen(app: app).open().openProfile()

        assertAppears(app.element(labelContaining: "Transactions"))
        XCTAssertTrue(app.element(labelContaining: "Transactions").label.contains("3"))
        XCTAssertTrue(app.element(labelContaining: "Active Days").label.contains("1"))
        XCTAssertFalse(app.element(labelContaining: "Total Income").exists)
        XCTAssertFalse(app.element(labelContaining: "Total Expenses").exists)

        let topSpending = app.element(labelContaining: "of all expenses")
        topSpending.scrollIntoView(in: app.collectionViews.firstMatch)
        XCTAssertTrue(topSpending.label.contains("Dining Out"))
        XCTAssertTrue(topSpending.label.contains("73%"))
        XCTAssertTrue(topSpending.label.contains("$120.00"))
    }

    func testPhotoMenuOffersChoosingAPhoto() {
        let app = launchApp()
        let profile = SettingsScreen(app: app).open().openProfile()

        profile.photoMenu.tap()

        assertAppears(app.buttons["Choose Photo"])
        XCTAssertFalse(app.buttons["Remove Photo"].exists, "Fotoğraf yokken kaldırma seçeneği olmamalı")
    }
}
