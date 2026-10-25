import XCTest

/// Tüm UI testlerinin temeli. Uygulama her testte temiz durumla (boş tercihler, bellek içi
/// veritabanı) açılır; bu yüzden testler birbirinden bağımsızdır ve sırası önemli değildir.
@MainActor
class FlowUITestCase: XCTestCase {

    static let launchTimeout: TimeInterval = 10
    static let timeout: TimeInterval = 5

    /// Uygulamayı açar; onboarding atlanıyorsa splash'ten sonra sekme çubuğunun gelmesini bekler.
    @discardableResult
    func launchApp(seeded: Bool = false, skipsOnboarding: Bool = true) -> XCUIApplication {
        continueAfterFailure = false

        let app = XCUIApplication.flow(seeded: seeded, skipsOnboarding: skipsOnboarding)
        app.launch()

        if skipsOnboarding {
            app.tabBars.firstMatch.assertExists(timeout: Self.launchTimeout, "Ana ekran açılmadı")
            app.buttons["homePrimaryButton"].assertExists("Ana sayfa yüklenmedi")
        }
        return app
    }

    /// Öğe belirene kadar bekler; belirmezse ekran görüntüsünü ekleyip testi düşürür.
    func assertAppears(
        _ element: XCUIElement,
        timeout: TimeInterval = FlowUITestCase.timeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        element.assertExists(timeout: timeout, message, file: file, line: line)
    }

    /// Öğe kaybolana kadar bekler.
    func assertDisappears(
        _ element: XCUIElement,
        timeout: TimeInterval = FlowUITestCase.timeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        element.assertDisappears(timeout: timeout, message, file: file, line: line)
    }

    /// Ekranın üstünde gösterilen toast'ın başlığını bekler.
    func assertToast(
        _ title: String,
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        assertAppears(app.element(labelContaining: title), "Toast gösterilmedi: \(title)", file: file, line: line)
    }
}
