import SwiftUI
import SwiftData

/// Dokununca düzenlemeyi açan, sola kaydırınca silme butonu gösteren satır.
/// VoiceOver'da silme, kaydırma yerine "Delete" eylemiyle yapılır.
struct TransactionRow: View {

    private static let deleteAnimationDuration: TimeInterval = 0.35

    @Environment(MainViewModel.self) private var mainVM
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.modelContext) private var modelContext

    @State private var horizontalDragAmount = 0.0
    @State private var rowSize: CGSize = .zero
    @State private var isDeleting = false

    let transaction: Transaction
    var showsDivider = true
    let onSelect: () -> Void

    var body: some View {
        let revealedWidth = max(0, -horizontalDragAmount)

        ZStack {
            SwipeDeleteButton(
                revealedWidth: revealedWidth,
                height: isDeleting ? 0 : rowSize.height,
                isFullyRevealed: revealedWidth == rowSize.width,
                action: deleteRow
            )

            Button(action: onSelect) {
                TransactionRowContent(transaction: transaction, showsDivider: showsDivider)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("transactionRow")
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                if !isDeleting {
                    rowSize = newValue
                }
            }
            .offset(x: horizontalDragAmount)
            .swipeableRow(horizontalDragAmount: $horizontalDragAmount)
            .accessibilityAction(named: "Delete", deleteRow)
        }
        .clipped()
        .frame(height: isDeleting ? 0 : nil)
        .opacity(isDeleting ? 0 : 1)
    }

    /// Satırı kapatma animasyonu bitince siler; silinemezse satırı geri açıp toast gösterir.
    private func deleteRow() {
        let rowWidth = rowSize.width

        withAnimation(.smooth(duration: Self.deleteAnimationDuration)) {
            horizontalDragAmount = -rowWidth
            isDeleting = true
        } completion: {
            do {
                try mainVM.deleteTransaction(transaction, in: modelContext)
            } catch {
                withAnimation(.smooth(duration: Self.deleteAnimationDuration)) {
                    isDeleting = false
                    horizontalDragAmount = .zero
                }
                toastManager.show(AppToasts.transactionDeleteError)
            }
        }
    }
}
