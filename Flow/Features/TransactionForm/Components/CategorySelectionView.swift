import SwiftUI

struct CategorySelectionView: View {

    @Environment(\.dismiss) private var dismiss

    let mode: CategorySelectionMode
    @Binding var selectedExpenseCategory: ExpenseCategory
    @Binding var selectedIncomeCategory: IncomeCategory

    private var isExpense: Bool {
        switch mode {
        case .picker(let kind): kind.wrappedValue == .expense
        case .fixed(let kind): kind == .expense
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SheetHeader("Select Category", buttonTitle: "Close", systemImage: "xmark", action: close)

            if case .picker(let kind) = mode {
                SegmentedPicker(title: "Transaction Type", selection: kind)
            }

            Group {
                if isExpense {
                    CategoryGrid(selection: $selectedExpenseCategory)
                } else {
                    CategoryGrid(selection: $selectedIncomeCategory)
                }
            }
            .transition(.opacity)
            .frame(minHeight: 350, alignment: .top)
            .animation(AppAnimation.selection, value: isExpense)
        }
    }

    private func close() {
        dismiss()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CategorySelectionView(
        mode: .picker(.constant(.expense)),
        selectedExpenseCategory: .constant(.dining),
        selectedIncomeCategory: .constant(.bonus)
    )
    .padding()
}
