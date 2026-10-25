import XCTest

/// Her görünüm yapılandırmasında (açık/koyu tema vb.) uygulamayı açıp ana sayfanın ekran
/// görüntüsünü test raporuna ekler.
final class LaunchUITests: FlowUITestCase {

    nonisolated override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    func testLaunchShowsHome() {
        let app = launchApp(seeded: true)
        assertAppears(HomeScreen(app: app).row(containing: "Dining Out"))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Home"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
