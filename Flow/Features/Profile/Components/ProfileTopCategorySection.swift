import SwiftUI

struct ProfileTopCategorySection: View {

    let category: ExpenseCategory
    let amount: Decimal
    /// 0...1 arası pay.
    let share: Double

    var body: some View {
        Section("Top Spending") {
            IconRow(
                icon: category.iconName,
                tint: category.color,
                title: Text(category.displayName),
                subtitle: Text("\(share, format: .percent.precision(.fractionLength(0))) of all expenses")
            ) {
                MoneyText(amount)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}
