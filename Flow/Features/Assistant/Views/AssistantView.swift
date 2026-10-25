import SwiftUI
import SwiftData

/// Cihaz üstü modelle çalışan finans asistanı. Sohbetler kaydedilir; geçmiş sheet'ten açılıp silinir.
struct AssistantView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.locale) private var locale
    @Environment(ToastManager.self) private var toastManager

    @State private var viewModel = AssistantViewModel()
    @State private var isHistoryPresented = false
    /// Yeni sohbete ya da geçmişten bir sohbete geçince artar; mesaj listesi bir bütün olarak değişir.
    @State private var chatGeneration = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isInputFocused: Bool
    @Namespace private var heroNamespace
    /// Son gönderilen mesaj ve uçtuğu kaynak; geçiş bitince temizlenir ki sonraki taslak
    /// aynı kimlikle eski balona bağlanmasın.
    @State private var hero: (messageID: UUID, source: AssistantHeroID)?

    var body: some View {
        let modelState = viewModel.modelState

        Group {
            if modelState == .ready {
                chat
            } else {
                AssistantDownloadView(
                    state: modelState,
                    onDownload: GemmaModelDownloader.shared.download(allowingCellular:),
                    onRetry: GemmaModelDownloader.shared.retry
                )
            }
        }
        .localizedNavigationTitle("Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("History", systemImage: "clock.arrow.circlepath") {
                    isHistoryPresented = true
                }
                .accessibilityIdentifier("assistantHistoryButton")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Chat", systemImage: "square.and.pencil") {
                    isInputFocused = false
                    withAnimation(AppAnimation.conversationSwap) {
                        viewModel.startNewConversation()
                        chatGeneration += 1
                    }
                }
                .disabled(viewModel.messages.isEmpty)
            }
        }
        .sheet(isPresented: $isHistoryPresented) {
            AssistantHistoryView(
                currentConversationID: viewModel.conversationID,
                onSelect: { id in
                    withAnimation(AppAnimation.conversationSwap) {
                        viewModel.openConversation(id: id, in: modelContext)
                        chatGeneration += 1
                    }
                },
                onDelete: deleteConversations
            )
        }
    }

    /// Mesaj listesi ve karşılama ekranı kardeş katmanlar; sohbet değişince yalnızca liste geçiş
    /// yapar. Giriş çubuğu ikisinin de dışında kalır, geçişte yerinden oynamaz.
    private var chat: some View {
        ZStack {
            messageList
                .id(chatGeneration)
                .transition(chatTransition)

            if viewModel.messages.isEmpty, !viewModel.isResponding {
                ScrollView {
                    AssistantWelcomeView(
                        onSelect: { suggestion, index in
                            send(suggestion.localized(in: locale), from: .suggestion(index))
                        },
                        heroNamespace: heroNamespace
                    )
                    .padding(.vertical, 24)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
                .dismissesInputFocusOnTap($isInputFocused)
                .transition(.opacity)
            }
        }
        .safeAreaInset(edge: .bottom) {
            AssistantInputBar(
                text: $viewModel.draft,
                isResponding: viewModel.isResponding,
                isFocused: $isInputFocused,
                onSend: { send(from: .draft) },
                onStop: viewModel.stopResponding,
                heroNamespace: heroNamespace
            )
        }
        .task {
            viewModel.prepare(in: modelContext, locale: locale)
        }
    }

    /// Kaydırma alanı da sohbetle birlikte değişir: içerik içeride değişseydi alttan hizalı
    /// ScrollView kaydırma konumunu düzeltirken giden mesajları aşağı iterdi.
    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.messages) { message in
                    AssistantMessageBubble(
                        role: message.role,
                        text: message.text,
                        heroID: hero?.messageID == message.id ? hero?.source : .message(message.id),
                        heroNamespace: heroNamespace
                    )
                }

                if let streamingText = viewModel.streamingText {
                    if viewModel.isLoadingModel {
                        Label("Loading the assistant model…", systemImage: "cpu")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .symbolEffect(.pulse)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else if streamingText.isEmpty {
                        AssistantTypingIndicator()
                    } else {
                        AssistantMessageBubble(role: .assistant, text: streamingText)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Label {
                        Text(errorMessage)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .defaultScrollAnchor(.bottom)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .scrollDismissesKeyboard(.interactively)
        .dismissesInputFocusOnTap($isInputFocused)
    }

    /// Sohbet değişirken eski sohbet bir bütün olarak yukarı kayıp solar, açılan sohbet aşağıdan gelir.
    private var chatTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 16)),
            removal: .opacity.combined(with: .offset(y: -24)).combined(with: .scale(scale: 0.96, anchor: .top))
        )
    }

    /// Mesaj, kaynağından (giriş alanı ya da öneri kartı) sohbetteki balonuna uçarak eklenir.
    private func send(_ text: String? = nil, from source: AssistantHeroID) {
        guard !reduceMotion else {
            viewModel.send(text, in: modelContext, locale: locale)
            return
        }

        let previousLast = viewModel.messages.last?.id
        withAnimation(AppAnimation.messageHero) {
            viewModel.send(text, in: modelContext, locale: locale)
            if let message = viewModel.messages.last, message.id != previousLast {
                hero = (message.id, source)
            }
        } completion: {
            hero = nil
        }
    }

    private func deleteConversations(_ ids: [UUID]) {
        do {
            try viewModel.deleteConversations(ids: ids, in: modelContext)
        } catch {
            toastManager.show(AppToasts.conversationDeleteError)
        }
    }
}

private extension View {

    /// Sohbet alanında boş bir yere dokununca klavye kapanır. Hareket butonlarla aynı anda
    /// tanındığı için öneri butonları ve metin seçimi çalışmaya devam eder.
    func dismissesInputFocusOnTap(_ isFocused: FocusState<Bool>.Binding) -> some View {
        contentShape(.rect)
            .simultaneousGesture(TapGesture().onEnded { isFocused.wrappedValue = false })
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AssistantView()
    }
    .previewEnvironment()
}
#endif
