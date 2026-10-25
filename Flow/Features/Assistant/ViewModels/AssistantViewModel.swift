import Foundation
import Observation
import SwiftData

/// Asistan ekranının durumu: açık sohbet, modelin yazmakta olduğu cevap ve Gemma oturumu.
/// Mesajlar SwiftData'ya yazılır; oturum ise yalnızca bellekte durur ve eski bir sohbet
/// açıldığında son mesajlar yeniden verilerek kurulur.
@Observable
final class AssistantViewModel {

    private static let titleLimit = 60

    private(set) var messages: [AssistantMessage] = []
    /// Model yazarken gelen kısmi cevap; cevap bitince `messages`'a eklenir.
    private(set) var streamingText: String?
    private(set) var errorMessage: LocalizedStringResource?
    private(set) var conversationID: UUID?
    var draft = ""

    /// Gemma motoru ilk soruda belleğe alınırken `true`; birkaç saniye sürebilir.
    private(set) var isLoadingModel = false

    var isResponding: Bool {
        streamingText != nil
    }

    @ObservationIgnored private var sessionTask: Task<GemmaChatSession, any Error>?
    @ObservationIgnored private var responseTask: Task<Void, Never>?
    @ObservationIgnored private let downloader: GemmaModelDownloader

    init(downloader: GemmaModelDownloader = .shared) {
        self.downloader = downloader
    }

    /// Model dosyasının durumu; `.ready` değilse sohbet yerine indirme ekranı gösterilir.
    var modelState: GemmaModelDownloader.State {
        downloader.state
    }

    /// Motoru ve oturumu önceden kurar; ilk cevabın gecikmesini azaltır.
    func prepare(in context: ModelContext, locale: Locale) {
        guard sessionTask == nil, modelState == .ready else { return }
        sessionTask = makeSession(container: context.container, locale: locale, history: messages)
    }

    // MARK: - Mesajlaşma

    func send(_ text: String? = nil, in context: ModelContext, locale: Locale) {
        let prompt = (text ?? draft).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isResponding else { return }

        if text == nil { draft = "" }
        errorMessage = nil
        let history = messages
        append(AssistantMessage(role: .user, text: prompt), in: context)

        streamingText = ""
        responseTask = Task {
            await respond(to: prompt, history: history, in: context, locale: locale)
        }
    }

    /// Yazılmakta olan cevabı durdurur; o ana kadar gelen kısım sohbette kalır.
    func stopResponding() {
        responseTask?.cancel()
    }

    private func respond(to prompt: String, history: [AssistantMessage], in context: ModelContext, locale: Locale) async {
        let conversationID = conversationID
        let sessionTask = sessionTask ?? makeSession(container: context.container, locale: locale, history: history)
        self.sessionTask = sessionTask

        do {
            try await stream(prompt, with: sessionTask)
        } catch where Self.isContextFull(error) {
            // Bağlam doldu: son mesajlarla yeni bir oturum açılıp soru bir kez daha sorulur.
            let freshSession = makeSession(container: context.container, locale: locale, history: history)
            self.sessionTask = freshSession
            do {
                try await stream(prompt, with: freshSession)
            } catch {
                handle(error)
            }
        } catch {
            handle(error)
        }

        // Bu arada başka bir sohbete geçildiyse cevap o sohbete yazılmaz.
        guard conversationID == self.conversationID else { return }
        if let streamingText, !streamingText.isEmpty {
            append(AssistantMessage(role: .assistant, text: streamingText), in: context)
        } else if errorMessage == nil, !Task.isCancelled {
            errorMessage = "Something went wrong. Please try again."
        }
        streamingText = nil
    }

    private func stream(_ prompt: String, with sessionTask: Task<GemmaChatSession, any Error>) async throws {
        streamingText = ""
        isLoadingModel = true
        defer { isLoadingModel = false }
        let session = try await sessionTask.value
        isLoadingModel = false
        try Task.checkCancellation()

        for try await text in try await session.streamResponse(to: prompt) {
            // Durdurulduktan sonra gelen parçalar yazılmaz.
            try Task.checkCancellation()
            streamingText = text
        }
    }

    private static func isContextFull(_ error: any Error) -> Bool {
        if case GemmaChatSession.SessionError.contextFull = error { true } else { false }
    }

    private func handle(_ error: any Error) {
        // Yarıda kesilen oturumun kaydı tutarsız kalabilir; sonraki soru yeni oturumla sorulur.
        sessionTask = nil
        guard !Task.isCancelled, !(error is CancellationError) else { return }
        print("Assistant response failed: \(error)")
        errorMessage = "Something went wrong. Please try again."
    }

    private func makeSession(container: ModelContainer, locale: Locale, history: [AssistantMessage]) -> Task<GemmaChatSession, any Error> {
        let currency = UserDefaults.appCurrency
        SpendingSummaryTool.use(SpendingReporter(container: container, currency: currency, locale: locale))
        let instructions = AssistantInstructions.text(
            now: .now,
            calendar: .current,
            locale: locale,
            currency: currency,
            dailyLimit: UserDefaults.dailySpendingLimit
        )
        let recent = history.suffix(AssistantInstructions.historyMessageLimit).map { message in
            var message = message
            message.text = String(message.text.prefix(AssistantInstructions.historyCharacterLimit))
            return message
        }
        return Task(priority: .userInitiated) {
            try await GemmaChatSession.make(instructions: instructions, history: Array(recent))
        }
    }

    // MARK: - Sohbetler

    func startNewConversation() {
        resetChat()
        conversationID = nil
        messages = []
    }

    func openConversation(id: UUID, in context: ModelContext) {
        guard id != conversationID else { return }
        do {
            let conversation = try context.assistantConversation(id: id)
            resetChat()
            conversationID = id
            messages = conversation.sortedMessages
        } catch {
            errorMessage = "The conversation couldn't be opened."
        }
    }

    /// Silme başarısız olursa hiçbir şey değişmez; açık sohbet silindiyse yeni sohbete geçilir.
    func deleteConversations(ids: [UUID], in context: ModelContext) throws {
        do {
            for id in ids {
                context.delete(try context.assistantConversation(id: id))
            }
            try context.save()
        } catch PersistenceError.notFound {
            // Başka cihazda silinmiş olabilir; kalanlar yine kaydedilir.
            try context.save()
        } catch {
            context.rollback()
            throw error
        }

        if let conversationID, ids.contains(conversationID) {
            startNewConversation()
        }
    }

    private func resetChat() {
        responseTask?.cancel()
        responseTask = nil
        streamingText = nil
        errorMessage = nil
        draft = ""
        sessionTask = nil
    }

    // MARK: - Kayıt

    /// Mesajı listeye ekler ve kaydeder; ilk mesajda sohbet oluşturulur ve başlığı o mesaj olur.
    /// Kayıt başarısız olsa da mesaj ekranda kalır, sohbet sürer.
    private func append(_ message: AssistantMessage, in context: ModelContext) {
        messages.append(message)

        do {
            let conversation: AssistantConversationEntity
            if let conversationID {
                conversation = try context.assistantConversation(id: conversationID)
            } else {
                conversation = AssistantConversationEntity(title: String(message.text.prefix(Self.titleLimit)))
                context.insert(conversation)
                conversationID = conversation.id
            }

            let entity = AssistantMessageEntity(message)
            context.insert(entity)
            entity.conversation = conversation
            conversation.updatedAt = message.createdAt
            try context.save()
        } catch {
            print("Failed to save assistant message: \(error)")
        }
    }
}
