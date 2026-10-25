import Testing
import Foundation
@testable import Flow

@Suite("Currency formatting")
struct CurrencyFormattingTests {

    private let enUS = Locale(identifier: "en_US")

    @Test func dollarUsesLocaleSymbolPlacementAndTwoDecimals() throws {
        let amount = try #require(Decimal(string: "1234.5"))
        #expect(amount.formatted(.currency(.dollar).locale(enUS)) == "$1,234.50")
    }

    @Test func liraUsesNarrowSymbol() {
        #expect(Decimal(10).formatted(.currency(.turkishLira).locale(enUS)).contains("₺"))
    }

    @Test func doubleOverloadMatchesDecimal() {
        #expect(12.5.formatted(.currency(.euro).locale(enUS)) == Decimal(12.5).formatted(.currency(.euro).locale(enUS)))
    }

    @Test func signedFormatShowsDirection() {
        let style = Decimal.FormatStyle.Currency.currency(.dollar).locale(enUS).sign(strategy: .always())
        #expect(Decimal(-5).formatted(style).hasPrefix("-"))
        #expect(Decimal(5).formatted(style).hasPrefix("+"))
    }
}
