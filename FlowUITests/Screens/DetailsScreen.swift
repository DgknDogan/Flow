import XCTest

/// Details sekmesi: dönem seçici, özet, grafik, bütçe, içgörüler ve kategoriler.
@MainActor
struct DetailsScreen {

    let app: XCUIApplication

    var list: XCUIElement { app.collectionViews.firstMatch }
    var rangePicker: XCUIElement { app.segmentedControls.firstMatch }
    var periodTitle: XCUIElement { app.staticTexts["periodTitle"] }
    var previousPeriodButton: XCUIElement { app.buttons["previousPeriodButton"] }
    var nextPeriodButton: XCUIElement { app.buttons["nextPeriodButton"] }
    var currentPeriodButton: XCUIElement { app.buttons["currentPeriodButton"] }
    var emptyStateAddButton: XCUIElement { app.buttons["emptyStateAddButton"] }

    @discardableResult
    func open() -> Self {
        app.tab("Details").tap(until: app.navigationBars["Details"], "Details açılmadı")
        return self
    }

    func selectRange(_ title: String) {
        rangePicker.buttons[title].tap()
    }

    /// Liste tembel yüklendiği için aşağıdaki bölümler kaydırılınca oluşur.
    func element(labelContaining text: String) -> XCUIElement {
        let element = app.element(labelContaining: text)
        element.scrollIntoView(in: list)
        return element
    }

    /// Bölüm başlıkları büyük harfle çizilebildiği için harf duyarsız arar.
    func header(_ text: String) -> XCUIElement {
        let header = app.staticTexts.matching(NSPredicate(format: "label ==[c] %@", text)).firstMatch
        header.scrollIntoView(in: list)
        return header
    }

    /// Kategori dağılımındaki satır (etiketinde yüzde payı geçer).
    func categoryRow(_ category: String) -> XCUIElement {
        let row = app.buttons.matching(NSPredicate(format: "label CONTAINS %@ AND label CONTAINS %@", category, "%")).firstMatch
        row.scrollIntoView(in: list)
        return row
    }

    // MARK: - Formats

    private static let locale = Locale(identifier: "en_US")

    /// `periodTitle` aylık görünümde: "October 2026".
    static func monthTitle(for date: Date) -> String {
        date.formatted(Date.FormatStyle(locale: locale).month(.wide).year())
    }

    static func yearTitle(for date: Date) -> String {
        date.formatted(Date.FormatStyle(locale: locale).year())
    }
}
