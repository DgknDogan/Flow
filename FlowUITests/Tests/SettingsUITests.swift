import XCTest

final class SettingsUITests: FlowUITestCase {

    // MARK: - Navigation

    func testEveryRowOpensItsScreen() {
        let settings = SettingsScreen(app: launchApp()).open()

        for route in SettingsScreen.Route.allCases {
            settings.open(route)
            settings.goBack()
        }

        settings.openProfile()
        settings.goBack()
    }

    func testRowsShowDefaultValues() {
        let settings = SettingsScreen(app: launchApp()).open()

        XCTAssertTrue(settings.row(.notifications).label.contains("Off"))
        XCTAssertTrue(settings.row(.currency).label.contains("$"))
        XCTAssertTrue(settings.row(.budget).label.contains("Not set"))
        XCTAssertTrue(settings.row(.appearance).label.contains("System"))
        XCTAssertTrue(settings.row(.language).label.contains("System"))
        XCTAssertTrue(settings.row(.security).label.contains("Off"))
        XCTAssertTrue(settings.row(.iCloudSync).label.contains("Off"), "UI testleri iCloud kapalı açılır")
        XCTAssertTrue(settings.profileRow.label.contains("Your Name"))
    }

    // MARK: - Currency

    func testChangingCurrencyReformatsAmounts() {
        let app = launchApp(seeded: true)
        let settings = SettingsScreen(app: app).open()

        settings.open(.currency)
        XCTAssertTrue(settings.option("US Dollar").isSelected)
        settings.option("Euro").tap()
        XCTAssertTrue(settings.option("Euro").isSelected)
        XCTAssertFalse(settings.option("US Dollar").isSelected)
        settings.goBack()

        XCTAssertTrue(settings.row(.currency).label.contains("€"))
        app.tab("Home").tap()
        assertAppears(HomeScreen(app: app).row(containing: "-€120.00"))
    }

    // MARK: - Appearance

    func testChoosingThemeMarksItSelected() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()

        settings.open(.appearance)
        XCTAssertTrue(settings.option("System").isSelected)
        settings.option("Dark").tap()
        XCTAssertTrue(settings.option("Dark").isSelected)
        XCTAssertFalse(settings.option("System").isSelected)
        settings.goBack()

        XCTAssertTrue(settings.row(.appearance).label.contains("Dark"))
    }

    // MARK: - Language

    /// Dil seçilince arayüz yeniden açmadan yeni dile geçer.
    func testChoosingLanguageSwitchesImmediately() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()

        settings.open(.language)
        XCTAssertTrue(settings.option("System").isSelected)

        settings.option("Türkçe").tap()
        XCTAssertTrue(settings.option("Türkçe").isSelected)
        assertAppears(app.navigationBars["Dil"])

        settings.option("Français").tap()
        assertAppears(app.navigationBars["Langue"])

        // Sisteme dönünce cihaz dili (simülatörde İngilizce) kullanılır; başlık eski dilde takılı kalmamalı.
        settings.option("Système").tap()
        assertAppears(app.navigationBars["Language"])
        settings.goBack()
        assertAppears(app.navigationBars["Settings"])
        XCTAssertTrue(settings.row(.language).label.contains("System"))
    }

    // MARK: - Budget

    func testSavingAndRemovingDailyLimit() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        let saveButton = app.navigationBars["Budget"].buttons["Save"]

        settings.open(.budget)
        XCTAssertFalse(saveButton.isEnabled, "Değişiklik yokken kaydedilemez")

        app.textFields["Daily limit"].tap()
        app.typeText("50")
        assertAppears(app.element(labelContaining: "Monthly Limit"))
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        settings.goBack()
        XCTAssertTrue(settings.row(.budget).label.contains("$50 / day"))

        settings.open(.budget)
        XCTAssertEqual(app.textFields["Daily limit"].value as? String, "50.00")
        app.buttons["Remove Budget"].tap()
        settings.goBack()
        XCTAssertTrue(settings.row(.budget).label.contains("Not set"))
    }

    // MARK: - iCloud

    func testChangingICloudSyncAsksForRestart() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        settings.open(.iCloudSync)
        let toggle = settings.toggle(titled: "iCloud Sync")
        let restartNotice = app.element(labelContaining: "Restart Required")
        XCTAssertFalse(toggle.isSwitchOn)
        XCTAssertFalse(restartNotice.exists)

        toggle.toggleSwitch()
        assertAppears(restartNotice)
        XCTAssertTrue(toggle.isSwitchOn)

        toggle.toggleSwitch()
        assertDisappears(restartNotice)
        XCTAssertFalse(toggle.isSwitchOn)
    }

    // MARK: - Notifications

    /// İlk açışta sistem izin ister; izin verilince günlük ve haftalık hatırlatıcı seçenekleri görünür.
    func testAllowingNotificationsShowsReminders() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        settings.open(.notifications)
        let dailyReminder = settings.toggle(titled: "Daily Reminder")
        XCTAssertFalse(dailyReminder.exists)

        settings.toggle(titled: "Allow Notifications").toggleSwitch()
        let allow = XCUIApplication.springboard.alerts.buttons["Allow"]
        if allow.waitForExistence(timeout: Self.timeout) {
            allow.tap()
        }

        assertAppears(dailyReminder)
        XCTAssertFalse(dailyReminder.isSwitchOn)
        dailyReminder.toggleSwitch()
        XCTAssertTrue(dailyReminder.isSwitchOn)

        let weeklyReminder = settings.toggle(titled: "Weekly Reminder")
        XCTAssertFalse(weeklyReminder.isSwitchOn)
        weeklyReminder.toggleSwitch()
        XCTAssertTrue(weeklyReminder.isSwitchOn)

        settings.goBack()
        XCTAssertTrue(settings.row(.notifications).label.contains("On"))
    }

    // MARK: - Security

    func testSecurityShowsAppLockToggleTurnedOff() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()

        settings.open(.security)

        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label ==[c] %@", "App Lock")).firstMatch.exists)
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.exists)
        XCTAssertFalse(toggle.isSwitchOn)
    }

    // MARK: - About & Support

    func testAboutShowsVersionAndLegalLinks() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()

        settings.open(.about)

        XCTAssertTrue(app.element(labelContaining: "Version").exists)
        XCTAssertTrue(app.element(labelContaining: "Terms of Service").exists)
        XCTAssertTrue(app.element(labelContaining: "Privacy Policy").exists)
        XCTAssertTrue(app.element(labelContaining: "Rate on the App Store").exists)
    }

    /// Yasal metinler Safari'ye çıkmadan uygulamanın içinde açılır.
    func testPrivacyPolicyOpensInApp() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        settings.open(.about)

        app.buttons.firstMatch(labelContaining: "Privacy Policy").tap()

        assertAppears(app.navigationBars["Privacy Policy"])
        XCTAssertTrue(app.element(labelContaining: "iCloud Sync").exists)
    }

    /// Simülatörde Mail olmadığı için adres panoya kopyalanır ve bilgi toast'ı gösterilir.
    func testContactSupportFallsBackToCopyingEmail() {
        let app = launchApp()
        let settings = SettingsScreen(app: app).open()
        let contact = app.buttons.firstMatch(labelContaining: "Contact Support")
        contact.scrollIntoView(in: settings.list)

        contact.tap()

        assertToast("Email Copied", in: app)
    }
}
