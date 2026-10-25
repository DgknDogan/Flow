import SwiftUI
import Charts

/// Kategorilerin paylarını gösteren halka grafik. Bir dilime dokununca ortada o kategorinin
/// tutarı, aksi halde toplam gösterilir.
struct CategoryDonutChart<Category: CategoryProtocol>: View {

    let shares: [CategoryShare<Category>]
    let total: Decimal

    @State private var selectedValue: Double?

    /// Açı seçimi kümülatif tutar olarak gelir; hangi dilime düştüğü sırayla bulunur.
    private var selectedShare: CategoryShare<Category>? {
        guard let selectedValue else { return nil }
        var cumulative = 0.0
        for share in shares {
            cumulative += share.amount.doubleValue
            if selectedValue <= cumulative {
                return share
            }
        }
        return nil
    }

    var body: some View {
        let selectedShare = selectedShare

        Chart(shares) { share in
            SectorMark(
                angle: .value("Amount", share.amount.doubleValue),
                innerRadius: .ratio(0.62),
                angularInset: 1.5
            )
            .cornerRadius(4)
            .foregroundStyle(share.category.color.gradient)
            .opacity(selectedShare == nil || selectedShare == share ? 1 : 0.35)
            .accessibilityLabel(Text(share.category.displayName))
            .accessibilityValue(Text(share.share, format: .percent.precision(.fractionLength(1))))
        }
        .chartAngleSelection(value: $selectedValue)
        .chartLegend(.hidden)
        .frame(height: 220)
        .overlay {
            centerLabel(for: selectedShare)
        }
        .padding(.vertical, 8)
        .animation(.snappy, value: selectedShare)
    }

    private func centerLabel(for share: CategoryShare<Category>?) -> some View {
        VStack(spacing: 2) {
            Group {
                if let share {
                    Text(share.category.displayName)
                } else {
                    Text("Total")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            MoneyText(share?.amount ?? total)
                .font(.title3.bold())
                .contentTransition(.numericText())
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: 120)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    List {
        CategoryDonutChart(
            shares: [
                CategoryShare(category: ExpenseCategory.dining, amount: 120, transactionCount: 1, share: 0.727),
                CategoryShare(category: ExpenseCategory.transport, amount: 45, transactionCount: 1, share: 0.273)
            ],
            total: 165
        )
    }
    .environment(AppState())
}
