import Foundation

/// Gemma, GPU'da bazen aracı çağırmak yerine adını düz metin olarak yazar ("get_spending_summary",
/// "get_spending_summary{}", "get_spending_summary(period="thisMonth")"). Bu metin kullanıcıya
/// gösterilmez; araç uygulama tarafından çalıştırılır ve sonuç modele verilir.
nonisolated struct LeakedToolCall: Equatable {

    static let toolName = "get_spending_summary"
    /// Gerçek bir cevap bu kadar kısa bir araç çağrısı metni olmaz; uzun metinler sızıntı sayılmaz.
    private static let maxLength = 300

    var period: String?
    var startDate: String?
    var endDate: String?
    var category: String?

    /// Metin bir araç çağrısı sızıntısıysa argümanlarıyla döner; değilse `nil`.
    init?(_ text: String) {
        let trimmed = Self.stripped(text)
        guard trimmed.hasPrefix(Self.toolName), trimmed.count <= Self.maxLength else { return nil }

        let arguments = Self.arguments(in: String(trimmed.dropFirst(Self.toolName.count)))
        period = arguments["period"]
        startDate = arguments["start_date"]
        endDate = arguments["end_date"]
        category = arguments["category"]
    }

    /// Akış sürerken metin henüz bir sızıntının başı olabilir mi ("get_sp…"); öyleyse gösterilmez.
    static func mayBeginLeak(_ text: String) -> Bool {
        let trimmed = stripped(text)
        return trimmed.isEmpty ? false : toolName.hasPrefix(trimmed) || trimmed.hasPrefix(toolName)
    }

    /// Kod bloğu işaretleri ve "tool_code" etiketi atılır.
    private static func stripped(_ text: String) -> String {
        text.replacing("`", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingPrefix("tool_code")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `{"period": "thisMonth"}` ve `(period="thisMonth")` biçimlerindeki anahtar-değer çiftleri.
    private static func arguments(in text: String) -> [String: String] {
        let pattern = /"?(period|start_date|end_date|category)"?\s*[:=]\s*"([^"]*)"/
        var result: [String: String] = [:]
        for match in text.matches(of: pattern) {
            let value = String(match.output.2).trimmingCharacters(in: .whitespaces)
            if !value.isEmpty { result[String(match.output.1)] = value }
        }
        return result
    }
}
