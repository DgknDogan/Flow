import SwiftUI
import SwiftData

/// Yeni işlem ekleme ve düzenleme için tek, adım adım ilerleyen form.
struct TransactionFormView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ToastManager.self) private var toastManager

    @State private var viewModel: TransactionFormViewModel
    private let onSave: (Transaction) -> Void

    init(mode: TransactionFormMode = .add, onSave: @escaping (Transaction) -> Void = { _ in }) {
        _viewModel = State(initialValue: TransactionFormViewModel(mode: mode))
        self.onSave = onSave
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            if case .edit(let transaction) = viewModel.mode {
                EditingBadge(transaction: transaction)
                    .padding(.bottom, 16)
            }

            Group {
                switch viewModel.step {
                case .category:
                    CategorySelectionView(
                        mode: viewModel.isEditing ? .fixed(viewModel.kind) : .picker($viewModel.kind),
                        selectedExpenseCategory: $viewModel.selectedExpenseCategory,
                        selectedIncomeCategory: $viewModel.selectedIncomeCategory
                    )
                    .transition(.blurReplace)
                case .date:
                    DateSelectionView(selectedDate: $viewModel.selectedDate, onBack: goBack)
                        .transition(.blurReplace)
                case .note:
                    NoteInputView(noteText: $viewModel.noteText, onBack: goBack)
                        .transition(.blurReplace)
                case .amount:
                    AmountInputView(amount: $viewModel.amount, onBack: goBack)
                        .transition(.blurReplace)
                }
            }
            .compositingGroup()
            .padding(.bottom)

            PrimaryButton(height: 50, action: primaryAction) {
                Text(primaryButtonTitle)
            }
            .accessibilityIdentifier("formPrimaryButton")
        }
        .padding([.horizontal, .top], 20)
    }

    private var primaryButtonTitle: LocalizedStringKey {
        if !viewModel.isLastStep {
            "Continue"
        } else if viewModel.isEditing {
            "Update"
        } else {
            "Save"
        }
    }

    private func primaryAction() {
        guard viewModel.isLastStep else {
            withAnimation(AppAnimation.stepTransition) {
                viewModel.goForward()
            }
            return
        }

        do {
            let saved = try viewModel.save(in: modelContext)
            // Başarı toast'ını sheet'i açan modifier gösterir (bkz. AddTransactionSheet).
            onSave(saved)
            SoundManager.instance.playSound()
            dismiss()
        } catch TransactionFormError.invalidAmount {
            toastManager.show(AppToasts.invalidAmount)
        } catch {
            toastManager.show(AppToasts.transactionError)
        }
    }

    private func goBack() {
        withAnimation(AppAnimation.stepTransition) {
            viewModel.goBack()
        }
    }
}

#if DEBUG
#Preview("Add") {
    Text("")
        .sheet(isPresented: .constant(true)) {
            DynamicSheet {
                TransactionFormView()
            }
        }
        .previewEnvironment()
}

#Preview("Edit") {
    Text("")
        .sheet(isPresented: .constant(true)) {
            DynamicSheet {
                TransactionFormView(mode: .edit(Transaction.samples[0]))
            }
        }
        .previewEnvironment()
}
#endif
