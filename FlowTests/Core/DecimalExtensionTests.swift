import Testing
import Foundation
@testable import Flow

@Suite("Decimal extensions")
struct DecimalExtensionTests {

    @Test func convertsToDouble() throws {
        let value = try #require(Decimal(string: "12.75"))
        #expect(value.doubleValue == 12.75)
    }

    @Test(arguments: [
        ("0", false),
        ("-1", false),
        ("0.01", true),
        ("999999.99", true),
        ("1000000", false)
    ])
    func validTransactionAmountBounds(text: String, isValid: Bool) throws {
        let value = try #require(Decimal(string: text))
        #expect(value.isValidTransactionAmount == isValid)
    }

    /// Günlük limit `Double` saklanıyor; hesaplarda kuruş altı artık kalmamalı.
    @Test(arguments: [(0.1, "0.1"), (12.5, "12.5"), (50, "50"), (19.999, "20")])
    func currencyAmountRoundsToCents(value: Double, expected: String) throws {
        #expect(Decimal(currencyAmount: value) == (try #require(Decimal(string: expected))))
    }
}
