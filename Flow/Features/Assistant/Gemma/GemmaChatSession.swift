import Foundation
@preconcurrency import LiteRTLM

/// Tek bir sohbetin Gemma oturumu. LiteRT-LM konuşmanın KV önbelleğini tuttuğu için talimatlar ve
/// önceki mesajlar yalnızca ilk soruda işlenir; sonraki sorularda sadece yeni metin işlenir.
actor GemmaChatSession {

    enum SessionError: Error {
        /// Bağlam penceresi doldu; son mesajlarla yeni bir oturum açılmalı.
        case contextFull
        /// Model yedek yoldan sonra da aracın adını cevap olarak yazdı.
        case toolCallLeaked
    }

    /// Kısa öneriler için yeterli; cevap uzadıkça ilk kelimeye kadar geçen süre değil, toplam süre artar.
    static let maxOutputTokens = 150
    /// Yeni soru, araç çıktısı ve cevap için bağlamda bırakılan pay.
    private static let reservedTokens = 1200

    private let conversation: Conversation
    /// Son turda model aracın adını yazdığı için yedek yol kullanıldı mı.
    private(set) var usedToolFallback = false

    private init(conversation: Conversation) {
        self.conversation = conversation
    }

    static func make(instructions: String, history: [AssistantMessage]) async throws -> GemmaChatSession {
        let engine = try await GemmaEngine.shared.engine()
        let config = ConversationConfig(
            systemMessage: Message(instructions, role: .system),
            initialMessages: history.map { Message($0.text, role: $0.role == .user ? .user : .model) },
            tools: [SpendingSummaryTool()],
            // Finans cevaplarında rakam uydurmayı azaltmak için düşük sıcaklık.
            samplerConfig: try SamplerConfig(topK: 40, topP: 0.95, temperature: 0.4),
            // Düşünme modu kısa cevaplarda yalnızca gecikme ekler.
            thinkingConfig: ThinkingConfig(enableThinking: false)
        )
        return GemmaChatSession(conversation: try await engine.createConversation(with: config))
    }

    /// Cevabın o ana kadar yazılmış tamamını parça parça verir. Akış bırakılırsa üretim de durur.
    func streamResponse(to prompt: String) throws -> AsyncThrowingStream<String, any Error> {
        if try conversation.getTokenCount() > GemmaEngine.contextTokenLimit - Self.reservedTokens {
            throw SessionError.contextFull
        }

        let (stream, continuation) = AsyncThrowingStream<String, any Error>.makeStream()
        let task = Task { await generate(prompt, into: continuation) }
        continuation.onTermination = { _ in
            task.cancel()
            Task { await self.cancel() }
        }
        return stream
    }

    private func generate(_ prompt: String, into continuation: AsyncThrowingStream<String, any Error>.Continuation) async {
        do {
            usedToolFallback = false
            let text = try await stream(Message(prompt), into: continuation)

            // Model aracı çağırmak yerine adını yazdıysa araç burada çalıştırılır ve sonuç
            // modele verilerek cevap bir kez daha istenir.
            if let leak = LeakedToolCall(text) {
                usedToolFallback = true
                let report = try SpendingSummaryTool.report(
                    period: leak.period,
                    startDate: leak.startDate,
                    endDate: leak.endDate,
                    category: leak.category
                )
                let retry = try await stream(Message(Self.fallbackPrompt(report: report)), into: continuation)
                if LeakedToolCall(retry) != nil {
                    throw SessionError.toolCallLeaked
                }
            }
            continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }
    }

    /// Bir mesajı gönderir ve cevabı akıtır. Araç sızıntısının başı olabilecek metin gösterilmez.
    private func stream(_ message: Message, into continuation: AsyncThrowingStream<String, any Error>.Continuation) async throws -> String {
        let chunks = conversation.sendMessageStream(
            message,
            maxOutputTokens: Self.maxOutputTokens,
            thinkingConfig: ThinkingConfig(enableThinking: false)
        )
        var text = ""
        for try await chunk in chunks {
            text += chunk.toString
            if !LeakedToolCall.mayBeginLeak(text) {
                continuation.yield(text)
            }
        }
        // Sızıntının başı gibi görünüp öyle bitmeyen kısa metin yine de gösterilir.
        if LeakedToolCall.mayBeginLeak(text), LeakedToolCall(text) == nil {
            continuation.yield(text)
        }
        return text
    }

    private static func fallbackPrompt(report: String) -> String {
        """
        Result of \(LeakedToolCall.toolName):
        \(report)

        Using only this data where it is relevant, answer my previous message now in plain sentences. Do not call or mention any tool.
        """
    }

    private func cancel() {
        try? conversation.cancel()
    }

    #if DEBUG
    /// Son turun motor ölçümleri; yalnızca benchmark modunda dolu gelir.
    struct TurnStats: Sendable {
        let timeToFirstToken: Double
        let prefillTokens: Int
        let prefillTokensPerSecond: Double
        let decodeTokens: Int
        let decodeTokensPerSecond: Double
        let contextTokens: Int
        let usedToolFallback: Bool
    }

    func lastTurnStats() throws -> TurnStats {
        let info = try conversation.getBenchmarkInfo()
        return TurnStats(
            timeToFirstToken: info.timeToFirstTokenInSecond,
            prefillTokens: info.lastPrefillTokenCount,
            prefillTokensPerSecond: info.lastPrefillTokensPerSecond,
            decodeTokens: info.lastDecodeTokenCount,
            decodeTokensPerSecond: info.lastDecodeTokensPerSecond,
            contextTokens: try conversation.getTokenCount(),
            usedToolFallback: usedToolFallback
        )
    }
    #endif
}
