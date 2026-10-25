import XCTest

final class OnboardingUITests: FlowUITestCase {

    func testFirstLaunchShowsFirstPage() {
        let app = launchApp(skipsOnboarding: false)

        assertAppears(app.staticTexts["Track Every Penny"])
        XCTAssertTrue(app.element(labelContaining: "Page 1 of 3").exists)
        XCTAssertTrue(app.buttons["Skip"].exists)
        XCTAssertTrue(app.buttons["Next"].exists)
    }

    func testNextWalksThroughPagesAndStartOpensHome() {
        let app = launchApp(skipsOnboarding: false)
        let next = app.buttons["Next"]
        assertAppears(next)

        next.tap()
        assertAppears(app.element(labelContaining: "Page 2 of 3"))

        next.tap()
        assertAppears(app.element(labelContaining: "Page 3 of 3"))
        XCTAssertFalse(next.exists, "Son sayfada buton Start olmalı")

        app.buttons["Start"].tap()
        assertAppears(app.tabBars.firstMatch)
        XCTAssertTrue(HomeScreen(app: app).emptyStateTitle.waitForExistence(timeout: Self.timeout))
    }

    func testSkipOpensHome() {
        let app = launchApp(skipsOnboarding: false)
        let skip = app.buttons["Skip"]
        assertAppears(skip)

        skip.tap()

        assertAppears(app.tabBars.firstMatch)
        XCTAssertFalse(app.buttons["Skip"].exists)
    }

    /// Onboarding görülmüşse splash'ten sonra doğrudan ana sayfa açılır.
    func testReturningUserSkipsOnboarding() {
        let app = launchApp()

        XCTAssertFalse(app.buttons["Skip"].exists)
        XCTAssertTrue(app.tab("Home").exists)
    }
}
