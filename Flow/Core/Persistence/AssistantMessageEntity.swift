import Foundation
import SwiftData

/// Sohbetteki tek bir mesaj. `role` ham değeri kayıtlı veride kullanılır.
@Model
nonisolated final class AssistantMessageEntity {

    var id: UUID = UUID()
    var role: String = AssistantMessage.Role.user.rawValue
    var text: String = ""
    var createdAt: Date = Date.now
    var conversation: AssistantConversationEntity?

    init(_ message: AssistantMessage) {
        self.id = message.id
        self.role = message.role.rawValue
        self.text = message.text
        self.createdAt = message.createdAt
    }

    func toDomain() -> AssistantMessage {
        AssistantMessage(
            id: id,
            role: AssistantMessage.Role(rawValue: role) ?? .assistant,
            text: text,
            createdAt: createdAt
        )
    }
}
