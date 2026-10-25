import SwiftUI

/// Harcanan / bütçe çubuğu ve kalan ya da aşan tutar.
/// Uyarı eşiğine kadar yeşil, eşikten sonra turuncu, bütçe aşılınca kırmızıdır.
struct BudgetProgressView: View {

    let budget: BudgetSummary
    let warningThreshold: Double

    @Environment(AppState.self) private var appState
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(format(budget.spent)) of \(format(budget.limit))")
                    .font(.headline)
                    .monospacedDigit()

                Spacer()

                Text(budget.progress, format: .percent.precision(.fractionLength(0)))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
            }

            ProgressView(value: min(budget.progress, 1))
                .tint(tint)

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(budget.isOverBudget ? Color.red : Color.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private var tint: Color {
        if budget.isOverBudget { return .red }
        return budget.progress >= warningThreshold ? .orange : .green
    }

    private var statusText: LocalizedStringKey {
        budget.isOverBudget
            ? "\(format(-budget.remaining)) over budget"
            : "\(format(budget.remaining)) left"
    }

    private func format(_ amount: Decimal) -> String {
        amount.formatted(.currency(appState.currency).locale(locale))
    }
}

#Preview {
    List {
        BudgetProgressView(
            budget: BudgetSummary(dailyLimit: 50, limit: 1_550, spent: 1_320, daysOverLimit: 4, dailyAllowance: 25),
            warningThreshold: 0.8
        )
    }
    .environment(AppState())
}
