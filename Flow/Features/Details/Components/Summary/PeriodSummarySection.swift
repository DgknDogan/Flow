import SwiftUI

/// Dönemin gelir, gider, net bakiye ve işlem sayısı kutuları.
struct PeriodSummarySection: View {

    let report: PeriodReport

    var body: some View {
        Section {
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    StatTile(icon: "arrow.down.circle.fill", tint: .green, title: "Income") {
                        MoneyText(report.totalIncome)
                    }
                    StatTile(icon: "arrow.up.circle.fill", tint: .red, title: "Expenses") {
                        MoneyText(report.totalExpense)
                    }
                }
                GridRow {
                    StatTile(icon: "plusminus.circle.fill", tint: .indigo, title: "Net Balance") {
                        // İşaret (+/−) dengenin yönünü renkten bağımsız gösterir.
                        MoneyText(report.netBalance, showsSign: report.netBalance != 0)
                            .foregroundStyle(report.netBalance < 0 ? Color.red : Color.primary)
                    }
                    StatTile(icon: "list.bullet.rectangle.fill", tint: .orange, title: "Transactions") {
                        Text(report.transactionCount, format: .number)
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
}
