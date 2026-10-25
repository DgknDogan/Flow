import XCTest

extension XCUIElementQuery {

    /// Etiketi verilen metni içeren ilk öğe. Birleştirilmiş erişilebilirlik etiketleri
    /// ("Dining Out, 72.7%") tam eşleşmeyle bulunamadığı için kullanılır.
    func firstMatch(labelContaining text: String) -> XCUIElement {
        matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }
}

extension XCUIElement {

    /// Türü ne olursa olsun, etiketi verilen metni içeren ilk alt öğe.
    func element(labelContaining text: String) -> XCUIElement {
        descendants(matching: .any).firstMatch(labelContaining: text)
    }

    /// Türü ne olursa olsun, kimliği verilen ilk alt öğe.
    func element(identifier: String) -> XCUIElement {
        descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// `Toggle` satırının tamamı tek bir anahtar öğesidir; ortasına dokunmak değeri her zaman
    /// değiştirmediği için sağdaki anahtara dokunulur.
    func toggleSwitch() {
        coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
    }

    /// Anahtarın açık olup olmadığı ("1" / "0").
    var isSwitchOn: Bool {
        (value as? String) == "1"
    }

    /// Öğe belirene kadar bekler; belirmezse ekran görüntüsünü rapora ekleyip testi düşürür.
    func assertExists(
        timeout: TimeInterval = FlowUITestCase.timeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard !waitForExistence(timeout: timeout) else { return }
        attachScreenshot()
        XCTFail(message.isEmpty ? "Bulunamadı: \(self)" : message, file: file, line: line)
    }

    /// Öğe kaybolana kadar bekler; kaybolmazsa ekran görüntüsünü rapora ekleyip testi düşürür.
    func assertDisappears(
        timeout: TimeInterval = FlowUITestCase.timeout,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard !waitForNonExistence(timeout: timeout) else { return }
        attachScreenshot()
        XCTFail(message.isEmpty ? "Kaybolmadı: \(self)" : message, file: file, line: line)
    }

    /// Dokunur ve `expected` belirene kadar bekler. Açılıştan hemen sonraki dokunuş, ekran
    /// geçişi sürerken kaybolabildiği için birkaç kez dener. Yalnızca tekrar dokunmanın zararsız
    /// olduğu yerlerde (sekme butonları, açılmamış sheet) kullanılmalı.
    func tap(
        until expected: XCUIElement,
        attempts: Int = 3,
        timeout: TimeInterval = 3,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for _ in 0..<attempts {
            tap()
            if expected.waitForExistence(timeout: timeout) {
                return
            }
        }
        expected.assertExists(timeout: 0, message, file: file, line: line)
    }

    private func attachScreenshot() {
        XCTContext.runActivity(named: "Ekran görüntüsü") { activity in
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.lifetime = .keepAlways
            activity.add(attachment)
        }
    }

    /// Öğe ekranda görünene kadar listeyi yukarı kaydırır.
    func scrollIntoView(in container: XCUIElement, maxSwipes: Int = 5) {
        var swipes = 0
        while !(exists && isHittable), swipes < maxSwipes {
            container.swipeUp()
            swipes += 1
        }
    }
}
