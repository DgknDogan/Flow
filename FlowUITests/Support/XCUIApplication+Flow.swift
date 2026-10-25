import XCTest

extension XCUIApplication {

    /// Test modunda, İngilizce arayüz ve `en_US` biçimleriyle (ör. "$1,000.00") açılacak uygulama.
    static func flow(seeded: Bool, skipsOnboarding: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [LaunchArgument.uiTesting, "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        if seeded {
            app.launchArguments.append(LaunchArgument.seedTransactions)
        }
        if skipsOnboarding {
            app.launchArguments.append(LaunchArgument.skipOnboarding)
        }
        return app
    }

    /// Sekme çubuğundaki buton. iOS 26 sekme çubuğu her butonu iki kez (cam efekti katmanıyla)
    /// sunduğu için ilk eşleşme alınır.
    func tab(_ title: String) -> XCUIElement {
        tabBars.buttons[title].firstMatch
    }

    /// Bildirim izni gibi sistem uyarılarını gösteren uygulama.
    static var springboard: XCUIApplication {
        XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }
}
