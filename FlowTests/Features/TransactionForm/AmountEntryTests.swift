import Testing
import Foundation
@testable import Flow

@Suite("AmountEntry")
struct AmountEntryTests {

    private func type(_ keys: [KeypadKey]) -> String {
        keys.reduce("") { AmountEntry.applying($1, to: $0) }
    }

    @Test func ignoresLeadingZero() {
        #expect(type([.digit(0), .digit(0)]) == "")
    }

    @Test func replacesLoneZero() {
        #expect(type([.decimalSeparator, .delete, .digit(5)]) == "5")
    }

    @Test func separatorFirstAddsZero() {
        #expect(type([.decimalSeparator, .digit(5)]) == "0.5")
    }

    @Test func allowsOnlyOneSeparator() {
        #expect(type([.digit(1), .decimalSeparator, .decimalSeparator, .digit(2)]) == "1.2")
    }

    @Test func limitsFractionDigits() {
        #expect(type([.digit(1), .decimalSeparator, .digit(2), .digit(3), .digit(4)]) == "1.23")
    }

    @Test func limitsIntegerDigits() {
        #expect(type(Array(repeating: .digit(9), count: 8)) == "999999")
    }

    @Test func largestEntryIsStillAValidAmount() {
        let text = type(Array(repeating: .digit(9), count: 8) + [.decimalSeparator, .digit(9), .digit(9)])
        #expect(Decimal(string: text)?.isValidTransactionAmount == true)
    }

    @Test func deleteRemovesLastCharacter() {
        #expect(AmountEntry.applying(.delete, to: "12.5") == "12.")
        #expect(AmountEntry.applying(.delete, to: "") == "")
    }

    @Test func displayUsesLocaleSeparator() {
        let turkish = Locale(identifier: "tr_TR")
        #expect(AmountEntry.displayText(for: "12.5", locale: turkish) == "12,5")
        #expect(AmountEntry.displayText(for: "", locale: turkish) == "0")
    }
}
