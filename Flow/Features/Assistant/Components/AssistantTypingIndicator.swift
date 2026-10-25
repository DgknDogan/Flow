import SwiftUI

/// Model ilk kelimeyi yazana kadar asistan balonunun yerinde gösterilir.
struct AssistantTypingIndicator: View {

    var body: some View {
        Image(systemName: "ellipsis")
            .font(.title3.weight(.semibold))
            .foregroundStyle(.secondary)
            .symbolEffect(.variableColor.iterative, options: .repeat(.continuous))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: AppRadius.badge))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Assistant is typing")
    }
}

#Preview {
    AssistantTypingIndicator()
        .padding()
}
