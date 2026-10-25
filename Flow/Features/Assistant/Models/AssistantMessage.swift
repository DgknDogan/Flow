import Foundation

nonisolated struct AssistantMessage: Identifiable, Hashable, Sendable {

    enum Role: String, Sendable {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    var text: String
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, text: String, createdAt: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}
