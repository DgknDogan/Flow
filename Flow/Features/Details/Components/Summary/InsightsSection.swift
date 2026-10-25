import SwiftUI

/// Ortalama, tahmin, önceki dönemle karşılaştırma, en yoğun gün/ay, harcamasız günler ve
/// tasarruf oranı.
struct InsightsSection: View {

    let report: PeriodReport

    @Environment(AppState.self) private var appState
    @Environment(\.locale) private var locale

    var body: some View {
        Section("Insights") {
            IconRow(icon: "divide.circle.fill", tint: .blue, title: Text(report.range.averageTitle)) {
                amountText(report.averageExpense)
            }

            if let projected = report.projectedExpense {
                IconRow(
                    icon: "chart.line.uptrend.xyaxis",
                    tint: .purple,
                    title: Text("Projected Spending"),
                    subtitle: Text(report.range.projectionSubtitle)
                ) {
                    amountText(projected)
                }
            }

            if let change = report.expenseChange {
                comparisonRow(change: change)
            }

            if let peak = report.peak {
                IconRow(
                    icon: "flame.fill",
                    tint: .orange,
                    title: Text(report.range.peakTitle),
                    subtitle: Text(peak.date, format: report.range.slotDateFormat)
                ) {
                    amountText(Decimal(currencyAmount: peak.amount))
                }
            }

            IconRow(
                icon: "leaf.fill",
                tint: .mint,
                title: Text("No-Spend Days"),
                subtitle: Text("Days without any expenses")
            ) {
                Text("\(report.noSpendDayCount) of \(report.elapsedDayCount)")
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }

            if let savingsRate = report.savingsRate {
                IconRow(
                    icon: "banknote.fill",
                    tint: .green,
                    title: Text("Savings Rate"),
                    subtitle: Text("Share of income left after expenses")
                ) {
                    Text(savingsRate, format: .percent.precision(.fractionLength(0)))
                        .fontWeight(.semibold)
                        .foregroundStyle(savingsRate < 0 ? Color.red : Color.primary)
                }
            }
        }
    }

    /// Gider arttıysa kırmızı, azaldıysa yeşil; yön ok ve işaretle de belirtilir.
    private func comparisonRow(change: Double) -> some View {
        let isIncrease = change > 0
        let previous = report.previousTotalExpense.formatted(.currency(appState.currency).locale(locale))

        return IconRow(
            icon: isIncrease ? "arrow.up.right" : "arrow.down.right",
            tint: isIncrease ? .red : .green,
            title: Text(report.range.comparisonTitle),
            subtitle: Text("Previously \(previous)")
        ) {
            Text(change, format: .percent.precision(.fractionLength(0)).sign(strategy: .always()))
                .fontWeight(.semibold)
                .foregroundStyle(isIncrease ? Color.red : Color.green)
        }
    }

    private func amountText(_ amount: Decimal) -> some View {
        MoneyText(amount)
            .fontWeight(.semibold)
            .monospacedDigit()
    }
}
