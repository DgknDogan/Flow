import Testing
@testable import Flow

@Suite("LeakedToolCall")
struct LeakedToolCallTests {

    /// iPhone 13 Pro GPU'da görülen biçimler.
    @Test func detectsBareToolName() {
        #expect(LeakedToolCall("get_spending_summary") == LeakedToolCall())
        #expect(LeakedToolCall("get_spending_summary{}") == LeakedToolCall())
        #expect(LeakedToolCall(" `get_spending_summary` \n") == LeakedToolCall())
    }

    @Test func readsArguments() throws {
        let json = try #require(LeakedToolCall(#"get_spending_summary{"period": "lastMonth", "category": "Dining Out"}"#))
        #expect(json.period == "lastMonth")
        #expect(json.category == "Dining Out")

        let call = try #require(LeakedToolCall(#"```tool_code get_spending_summary(period="custom", start_date="2026-10-01", end_date="2026-10-07")```"#))
        #expect(call.period == "custom")
        #expect(call.startDate == "2026-10-01")
        #expect(call.endDate == "2026-10-07")
    }

    @Test func ignoresRealAnswers() {
        #expect(LeakedToolCall("Bu ay toplam **$165,00** harcadın.") == nil)
        #expect(LeakedToolCall("") == nil)
    }

    /// Akış sırasında sızıntının başı gizlenir; gerçek cevap ilk farklı harfte görünür.
    @Test func holdsBackOnlyPossibleLeakPrefixes() {
        #expect(LeakedToolCall.mayBeginLeak("get_sp"))
        #expect(LeakedToolCall.mayBeginLeak("get_spending_summary{"))
        #expect(!LeakedToolCall.mayBeginLeak("Gelirin"))
        #expect(!LeakedToolCall.mayBeginLeak(""))
    }
}

private extension LeakedToolCall {
    /// Argümansız sızıntı.
    init() {
        self.init("get_spending_summary")!
    }
}
