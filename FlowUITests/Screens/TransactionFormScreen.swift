import XCTest

/// İşlem ekleme/düzenleme sheet'i: kategori → tarih → not → tutar.
@MainActor
struct TransactionFormScreen {

    let app: XCUIApplication

    var primaryButton: XCUIElement { app.buttons["formPrimaryButton"] }
    var amountDisplay: XCUIElement { app.staticTexts["amountDisplay"] }
    var noteField: XCUIElement { app.element(identifier: "noteField") }
    var kindPicker: XCUIElement { app.segmentedControls.firstMatch }
    var editingBadge: XCUIElement { app.element(labelContaining: "Editing Transaction") }
    var backButton: XCUIElement { app.buttons["Back"] }
    var closeButton: XCUIElement { app.buttons["Close"] }

    func title(_ text: String) -> XCUIElement {
        app.staticTexts[text]
    }

    @discardableResult
    func waitUntilShown() -> Self {
        primaryButton.assertExists("İşlem formu açılmadı")
        return self
    }

    func selectKind(_ kind: String) {
        kindPicker.buttons[kind].tap()
    }

    func selectCategory(_ category: String) {
        app.buttons[category].tap()
    }

    func next() {
        primaryButton.tap()
    }

    func typeNote(_ note: String) {
        noteField.tap()
        app.typeText(note)
    }

    /// Tutar tuş takımında basar; "." ondalık ayırıcı tuşudur.
    func enterAmount(_ amount: String) {
        for character in amount {
            let label = character == "." ? "Decimal separator" : String(character)
            app.buttons[label].tap()
        }
    }

    func deleteDigits(_ count: Int) {
        for _ in 0..<count {
            app.buttons["Delete"].tap()
        }
    }

    /// Kategori adımından tutar adımına geçer.
    func goToAmountStep() {
        next()
        next()
        next()
        title("Set Amount").assertExists("Tutar adımına geçilemedi")
    }

    /// Bütün adımları doldurup kaydeder.
    func addTransaction(kind: String = "Expense", category: String, note: String? = nil, amount: String) {
        if kind != "Expense" {
            selectKind(kind)
        }
        selectCategory(category)
        next()
        next()
        if let note {
            typeNote(note)
        }
        next()
        enterAmount(amount)
        next()
    }
}
