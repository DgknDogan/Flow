import XCTest

/// Ana sayfa: gün seçici, arama, işlem listesi ve sağ üstteki butonlar.
@MainActor
struct HomeScreen {

    let app: XCUIApplication

    var primaryButton: XCUIElement { app.buttons["homePrimaryButton"] }
    var monthPickerButton: XCUIElement { app.buttons["monthPickerButton"] }
    var searchField: XCUIElement { app.element(identifier: "searchField") }
    var emptyStateAddButton: XCUIElement { app.buttons["emptyStateAddButton"] }
    var emptyStateTitle: XCUIElement { app.staticTexts["No Transactions Yet"] }
    var emptyDayTitle: XCUIElement { app.staticTexts["No Transactions on This Day"] }
    var noSearchResults: XCUIElement { app.element(labelContaining: "No Results") }
    var rows: XCUIElementQuery { app.buttons.matching(identifier: "transactionRow") }

    /// Etiketinde verilen metin (kategori, not ya da tutar) geçen satır.
    func row(containing text: String) -> XCUIElement {
        rows.firstMatch(labelContaining: text)
    }

    @discardableResult
    func openAddTransaction() -> TransactionFormScreen {
        let form = TransactionFormScreen(app: app)
        primaryButton.tap(until: form.primaryButton, "İşlem formu açılmadı")
        return form
    }

    @discardableResult
    func openEditor(forRowContaining text: String) -> TransactionFormScreen {
        row(containing: text).tap()
        return TransactionFormScreen(app: app).waitUntilShown()
    }

    /// Arama kapsülüne dokunup klavyeyle yazar. Metin alanı yalnızca odaktayken dokunuş aldığı
    /// için dokunuşu kapsül karşılar.
    func search(_ text: String) {
        searchField.tap()
        app.typeText(text)
    }

    func selectDay(_ date: Date) {
        app.buttons[Self.dayLabel(for: date)].tap()
    }

    func selectMonth(of date: Date) {
        monthPickerButton.tap()
        let month = app.buttons[date.formatted(Self.monthFormat)]
        month.assertExists("Ay listesinde yok: \(month)")
        month.tap()
    }

    /// Satırı sola kaydırıp açılan silme alanına dokunur. Silme butonu VoiceOver'dan gizli
    /// (yerine "Delete" eylemi var) olduğu için konumla dokunulur: satırın sağ ucundaki 80pt.
    func deleteRow(containing text: String) {
        let row = row(containing: text)
        let rowFrame = row.frame
        row.swipeLeft()

        let window = app.windows.firstMatch
        let deleteArea = window.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: window.frame.maxX - 16 - 40, dy: rowFrame.midY))
        deleteArea.tap()
    }

    // MARK: - Formats

    private static let locale = Locale(identifier: "en_US")

    /// `DayChip` erişilebilirlik etiketi: "October 22".
    static func dayLabel(for date: Date) -> String {
        date.formatted(Date.FormatStyle(locale: locale).day().month(.wide))
    }

    /// `MonthPickerList` satırı: "October 2026".
    static let monthFormat = Date.FormatStyle(locale: locale).month(.wide).year()
}
