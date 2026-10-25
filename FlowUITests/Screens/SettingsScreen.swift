import XCTest

/// Ayarlar sekmesi ve alt ekranları.
@MainActor
struct SettingsScreen {

    /// `MainRoutes` durumları; satır kimlikleri "settingsRow.<route>" biçimindedir.
    enum Route: String, CaseIterable {
        case notifications
        case currency
        case budget
        case appearance
        case language
        case security
        case iCloudSync
        case about

        var screenTitle: String {
            switch self {
            case .notifications: "Notifications"
            case .currency: "Currency"
            case .budget: "Budget"
            case .appearance: "Appearance"
            case .language: "Language"
            case .security: "Security"
            case .iCloudSync: "iCloud Sync"
            case .about: "About"
            }
        }
    }

    let app: XCUIApplication

    var list: XCUIElement { app.collectionViews.firstMatch }
    var profileRow: XCUIElement { app.buttons.firstMatch(labelContaining: "View profile") }

    func row(_ route: Route) -> XCUIElement {
        app.buttons["settingsRow.\(route.rawValue)"]
    }

    @discardableResult
    func open() -> Self {
        app.tab("Settings").tap(until: app.navigationBars["Settings"], "Ayarlar açılmadı")
        return self
    }

    func open(_ route: Route) {
        let row = row(route)
        row.scrollIntoView(in: list)
        row.tap()
        app.navigationBars[route.screenTitle].assertExists("\(route.screenTitle) ekranı açılmadı")
    }

    @discardableResult
    func openProfile() -> ProfileScreen {
        // Liste aşağı kaydırılmışsa satır küçülen başlığın altında kalır ama yine de "hittable"
        // sayılır; dokunmadan önce listenin başına dönülür.
        list.swipeDown()
        profileRow.tap()
        return ProfileScreen(app: app).waitUntilShown()
    }

    /// Gezinme çubuğundaki geri butonu. Üstte toast görünürken dokunuş ona gidebildiği için
    /// Ayarlar görünene kadar tekrar denenir.
    func goBack() {
        app.navigationBars.buttons.element(boundBy: 0)
            .tap(until: app.navigationBars["Settings"], "Ayarlar'a dönülemedi")
    }

    /// Seçim listelerindeki (para birimi, tema) satır.
    func option(_ title: String) -> XCUIElement {
        app.buttons[title]
    }

    func toggle(titled title: String) -> XCUIElement {
        app.switches.firstMatch(labelContaining: title)
    }
}
