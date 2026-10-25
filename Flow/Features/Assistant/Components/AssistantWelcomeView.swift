import SwiftUI

/// Boş sohbette gösterilir: kısa bir tanıtım ve dokununca gönderilen örnek sorular.
struct AssistantWelcomeView: View {

    static let suggestions: [LocalizedStringResource] = [
        "How much did I spend this month?",
        "Which category do I spend the most on?",
        "How does this month compare to last month?",
        "What were my largest expenses this week?"
    ]

    /// Seçilen öneri ve sırası; sıra, kartın balona uçtuğu geçişin kimliğidir.
    let onSelect: (_ suggestion: LocalizedStringResource, _ index: Int) -> Void
    var heroNamespace: Namespace.ID?

    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize = 80.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Öğeler ekrana gelince sırayla belirir: rozet, başlık, öneriler, not.
    @State private var isRevealed = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: Tabs.assistant.systemImage)
                .font(.system(size: badgeSize * 0.4, weight: .semibold))
                .foregroundStyle(Color.accentColor.gradient)
                .frame(width: badgeSize, height: badgeSize)
                .background(Color.accentColor.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
                .scaleEffect(isRevealed || reduceMotion ? 1 : 0.6)
                .revealed(isRevealed, step: 0, reduceMotion: reduceMotion)

            VStack(spacing: 8) {
                Text("Your Finance Assistant")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                Text("Ask about your spending and income. Everything runs on your device, so your data never leaves it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .revealed(isRevealed, step: 1, reduceMotion: reduceMotion)

            VStack(spacing: 8) {
                ForEach(Array(Self.suggestions.enumerated()), id: \.element.key) { index, suggestion in
                    Button {
                        onSelect(suggestion, index)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: AppRadius.badge))
                    .assistantHero(.suggestion(index), in: heroNamespace)
                    .revealed(isRevealed, step: 2 + index, reduceMotion: reduceMotion)
                }
            }

            Text("Answers may be inaccurate and aren't financial advice.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .revealed(isRevealed, step: 2 + Self.suggestions.count, reduceMotion: reduceMotion)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .onAppear { isRevealed = true }
    }
}

private extension View {

    /// Karşılama öğesini sırası gelince solarak ve aşağıdan yükselerek gösterir.
    func revealed(_ isRevealed: Bool, step: Int, reduceMotion: Bool) -> some View {
        opacity(isRevealed ? 1 : 0)
            .offset(y: isRevealed || reduceMotion ? 0 : 14)
            .animation(AppAnimation.stepTransition.delay(Double(step) * AppAnimation.welcomeStagger), value: isRevealed)
    }
}

#Preview {
    AssistantWelcomeView { _, _ in }
}
