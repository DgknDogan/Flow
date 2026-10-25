import XCTest

/// Ayarlar → Profil ekranı.
@MainActor
struct ProfileScreen {

    let app: XCUIApplication

    var nameRow: XCUIElement { app.buttons.firstMatch(labelContaining: "Name") }
    var photoMenu: XCUIElement { app.buttons["Profile photo"] }
    var nameAlert: XCUIElement { app.alerts["Edit Name"] }

    @discardableResult
    func waitUntilShown() -> Self {
        app.navigationBars["Profile"].assertExists("Profil açılmadı")
        return self
    }

    /// İsim düzenleme uyarısını açar, alanı temizleyip yazar ve verilen butona basar.
    func editName(to name: String, confirmWith button: String = "Save") {
        nameRow.tap()
        nameAlert.assertExists("İsim uyarısı açılmadı")

        let field = nameAlert.textFields.firstMatch
        field.tap()
        app.typeText(name)
        nameAlert.buttons[button].tap()
    }
}
