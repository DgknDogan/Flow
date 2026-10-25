import Testing
import Foundation
@testable import Flow

@Suite("AssistantInstructions")
struct AssistantInstructionsTests {

    private func text(language: String, dailyLimit: Double? = nil) throws -> String {
        AssistantInstructions.text(
            now: try TestCalendar.date(2026, 3, 18),
            calendar: TestCalendar.gmt,
            locale: Locale(identifier: language),
            currency: .dollar,
            dailyLimit: dailyLimit
        )
    }

    /// Cevap dili açıkça söylenir ve örnekler o dilde verilir.
    @Test func statesResponseLanguageWithExamplesInIt() throws {
        let turkish = try text(language: "tr_TR")
        #expect(turkish.contains("Respond only in Turkish"))
        #expect(turkish.contains("Nasıl daha fazla tasarruf edebilirim?"))
        #expect(!turkish.contains("How can I save more?"))

        let french = try text(language: "fr_FR")
        #expect(french.contains("Respond only in French"))
        #expect(french.contains("Comment puis-je épargner davantage ?"))

        let italian = try text(language: "it_IT")
        #expect(italian.contains("Respond only in Italian"))
        #expect(italian.contains("Come posso risparmiare di più?"))

        let german = try text(language: "de_DE")
        #expect(german.contains("Respond only in German"))
        #expect(german.contains("Wie kann ich mehr sparen?"))
    }

    /// Değişen bilgiler sonda; talimatların başı günden güne aynı kalır.
    @Test func dynamicFactsComeAfterStaticPart() throws {
        let instructions = try text(language: "en_US", dailyLimit: 50)
        let lines = instructions.components(separatedBy: "\n")

        #expect(lines.first == "You are the personal finance assistant inside Flow, a budgeting app.")
        #expect(lines.suffix(2).first?.hasPrefix("Today is Wednesday, 2026-03-18.") == true)
        #expect(lines.last?.hasPrefix("The user's daily spending limit is") == true)
    }
}
