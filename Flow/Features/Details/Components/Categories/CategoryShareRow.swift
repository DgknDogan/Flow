import SwiftUI

/// Kategorinin dönemdeki toplamı, işlem sayısı ve payı.
struct CategoryShareRow<Category: CategoryProtocol>: View {

    let share: CategoryShare<Category>

    @Environment(\.locale) private var locale

    var body: some View {
        IconRow(
            icon: share.category.iconName,
            tint: share.category.color,
            title: Text(share.category.displayName),
            subtitle: Text("^[\(share.transactionCount) transaction](inflect: true) · \(percentText)")
        ) {
            MoneyText(share.amount)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }

    private var percentText: String {
        share.share.formatted(.percent.precision(.fractionLength(1)).locale(locale))
    }
}

#Preview {
    List {
        CategoryShareRow(share: CategoryShare(category: ExpenseCategory.dining, amount: 120, transactionCount: 3, share: 0.727))
    }
    .environment(AppState())
}
