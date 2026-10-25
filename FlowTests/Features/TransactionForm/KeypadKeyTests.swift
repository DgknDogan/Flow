import Testing
@testable import Flow

@Suite("KeypadKey")
struct KeypadKeyTests {

    @Test func layoutIsAPhoneKeypad() {
        let layout = KeypadKey.layout

        #expect(layout.count == 12)
        #expect(Array(layout.prefix(9)) == (1...9).map(KeypadKey.digit))
        #expect(Array(layout.suffix(3)) == [.delete, .digit(0), .decimalSeparator])
    }

    @Test func everyKeyIsUnique() {
        #expect(Set(KeypadKey.layout).count == KeypadKey.layout.count)
    }
}
