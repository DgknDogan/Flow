import SwiftUI
import SwiftData

/// Kayıtlı sohbetler: dokununca sohbet açılır, kaydırınca ya da "Delete All" ile silinir.
struct AssistantHistoryView: View {

    let currentConversationID: UUID?
    let onSelect: (UUID) -> Void
    let onDelete: ([UUID]) -> Void

    @Query(sort: \AssistantConversationEntity.updatedAt, order: .reverse)
    private var conversations: [AssistantConversationEntity]

    @Environment(\.dismiss) private var dismiss
    @State private var isDeleteAllConfirmationPresented = false

    var body: some View {
        NavigationStack {
            Group {
                if conversations.isEmpty {
                    ContentUnavailableView(
                        "No Conversations",
                        systemImage: "bubble.left.and.text.bubble.right",
                        description: Text("Your chats with the assistant will appear here.")
                    )
                } else {
                    list
                }
            }
            .insetGroupedScreen("History")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") { dismiss() }
                }
                if !conversations.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete All", systemImage: "trash", role: .destructive) {
                            isDeleteAllConfirmationPresented = true
                        }
                        .confirmationDialog(
                            "Delete all conversations?",
                            isPresented: $isDeleteAllConfirmationPresented,
                            titleVisibility: .visible
                        ) {
                            Button("Delete All", role: .destructive) {
                                onDelete(conversations.map(\.id))
                            }
                        } message: {
                            Text("This can't be undone.")
                        }
                    }
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(conversations) { conversation in
                Button {
                    onSelect(conversation.id)
                    dismiss()
                } label: {
                    row(for: conversation)
                }
                .tint(.primary)
            }
            .onDelete { offsets in
                onDelete(offsets.map { conversations[$0].id })
            }
        }
    }

    private func row(for conversation: AssistantConversationEntity) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.body)
                    .lineLimit(1)
                Text(conversation.updatedAt, format: .relative(presentation: .named))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if conversation.id == currentConversationID {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
                    .accessibilityLabel("Open")
            }
        }
    }
}

#if DEBUG
#Preview {
    AssistantHistoryView(currentConversationID: nil, onSelect: { _ in }, onDelete: { _ in })
        .previewEnvironment()
}
#endif
