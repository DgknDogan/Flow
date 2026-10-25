import SwiftUI

/// Günlük limit girilmişse dönem bütçesinin durumu; girilmemişse bütçe ayarına kısayol.
struct BudgetSection: View {

    let budget: BudgetSummary?

    @Environment(AppState.self) private var appState

    var body: some View {
        Section {
            if let budget {
                BudgetProgressView(budget: budget, warningThreshold: appState.budgetWarningThreshold)

                IconRow(
                    icon: "exclamationmark.triangle.fill",
                    tint: .red,
                    title: Text("Days Over Limit"),
                    subtitle: Text("Daily limit: \(budget.dailyLimit, format: .currency(appState.currency))")
                ) {
                    Text(budget.daysOverLimit, format: .number)
                        .fontWeight(.semibold)
                }

                if let allowance = budget.dailyAllowance {
                    IconRow(
                        icon: "checkmark.shield.fill",
                        tint: .green,
                        title: Text("Safe to Spend"),
                        subtitle: Text("Per day for the rest of this period")
                    ) {
                        MoneyText(allowance)
                            .fontWeight(.semibold)
                    }
                }
            } else {
                // Details'in NavigationStack'i de `MainRoutes` hedeflerini tanır.
                NavigationLink(value: MainRoutes.budget) {
                    IconRow(
                        icon: "wallet.bifold.fill",
                        tint: .indigo,
                        title: "Set a Daily Limit",
                        subtitle: "See how your spending compares to a budget."
                    )
                }
            }
        } header: {
            Text("Budget")
        }
    }
}
