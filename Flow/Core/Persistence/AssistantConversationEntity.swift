import Foundation
import SwiftData

/// Asistanla yapılan bir sohbet. CloudKit kuralları gereği alanların varsayılanı var ve ilişki
/// optional; sohbet silinince mesajları da silinir.
@Model
nonisolated final class AssistantConversationEntity {
    #Index<AssistantConversationEntity>([\.updatedAt])

    var id: UUID = UUID()
    var title: String = ""
    var createdAt: Date = Date.now
    /// Son mesajın zamanı; geçmiş listesi buna göre sıralanır.
    var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \AssistantMessageEntity.conversation)
    var messages: [AssistantMessageEntity]? = []

    init(id: UUID = UUID(), title: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }

    /// Mesajlar gönderilme sırasıyla.
    var sortedMessages: [AssistantMessage] {
        (messages ?? [])
            .sorted { $0.createdAt < $1.createdAt }
            .map { $0.toDomain() }
    }
}

extension ModelContext {

    func assistantConversation(id: UUID) throws -> AssistantConversationEntity {
        var descriptor = FetchDescriptor<AssistantConversationEntity>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let entity = try fetch(descriptor).first else {
            throw PersistenceError.notFound
        }
        return entity
    }
}
