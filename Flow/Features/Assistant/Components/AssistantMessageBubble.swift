import SwiftUI

/// Sohbetteki tek mesaj. Kullanıcı mesajları sağda vurgu renginde, asistanınkiler solda.
/// Model cevaplarında kalın yazı ve listeler için satır içi Markdown işlenir.
struct AssistantMessageBubble: View {

    let role: AssistantMessage.Role
    let text: String
    /// Gönderim geçişinde balonun eşleştiği kaynak; `nil` ise geçişe katılmaz.
    var heroID: AssistantHeroID?
    var heroNamespace: Namespace.ID?

    var body: some View {
        let isUser = role == .user

        Text(formattedText)
            .font(.body)
            .foregroundStyle(isUser ? Color.white : Color.primary)
            .textSelection(.enabled)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isUser ? AnyShapeStyle(Color.accentColor.gradient) : AnyShapeStyle(Color(.secondarySystemBackground)),
                in: .rect(cornerRadius: AppRadius.badge)
            )
            .assistantHero(heroID, in: heroNamespace)
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .padding(isUser ? .leading : .trailing, 40)
    }

    private var formattedText: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}

#Preview {
    VStack {
        AssistantMessageBubble(role: .user, text: "Bu ay ne kadar harcadım?")
        AssistantMessageBubble(role: .assistant, text: "Bu ay toplam **₺4.250** harcadın. En çok *Market* kategorisine harcama yaptın.")
    }
    .padding()
}
