import SwiftUI

/// Mesaj yazma alanı. Cevap yazılırken gönder butonu durdurma butonuna dönüşür.
struct AssistantInputBar: View {

    @Binding var text: String
    let isResponding: Bool
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    let onStop: () -> Void
    /// Yazılan metnin gönderilince balona uçtuğu geçiş için.
    var heroNamespace: Namespace.ID?

    /// Tek satırlık barın yüksekliğinin yarısı. `AppRadius.card` (30) bu yükseklikten büyük kaldığı
    /// için şekil yarıya kırpılıyor, ama dokununca beliren glass vurgusu kırpılmamış köşeyi çiziyordu.
    private static let cornerRadius = 22.0

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Ask about your money", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .focused(isFocused)
                .submitLabel(.send)
                .onSubmit(send)
                .padding(.vertical, 10)
                .padding(.leading, 16)
                // Metin varken alanın çerçevesi geçişin kaynağıdır; gönderilince metin silinir ve
                // eklenen balon bu çerçeveden yerine kayar.
                .background {
                    if canSend {
                        Color.clear.assistantHero(.draft, in: heroNamespace)
                    }
                }
                .accessibilityIdentifier("assistantInputField")

            Button(action: isResponding ? onStop : send) {
                Label(
                    isResponding ? "Stop" : "Send",
                    systemImage: isResponding ? "stop.circle.fill" : "arrow.up.circle.fill"
                )
                .labelStyle(.iconOnly)
                .font(.title)
                .contentTransition(.symbolEffect(.replace))
            }
            .disabled(!isResponding && !canSend)
            .padding(4)
            .accessibilityIdentifier("assistantSendButton")
        }
        .frame(minHeight: Self.cornerRadius * 2)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Self.cornerRadius))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func send() {
        guard canSend, !isResponding else { return }
        onSend()
    }
}
