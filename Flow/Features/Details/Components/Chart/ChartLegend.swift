import SwiftUI

/// Grafikteki kesikli çizgilerin açıklaması: ortalama (gri) ve limit (pembe).
struct ChartLegend: View {

    let range: DateTabs
    let average: Double?
    let limit: Double?

    var body: some View {
        HStack(spacing: 16) {
            if let average {
                item(title: range.averageLegend, amount: average, color: .gray)
            }

            if let limit {
                item(title: range.limitLegend, amount: limit, color: .pink)
            }
        }
    }

    private func item(title: LocalizedStringResource, amount: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "line.diagonal")
                .rotationEffect(.degrees(45))
                .foregroundStyle(color)
                .accessibilityHidden(true)

            Text(title)
                .foregroundStyle(.secondary)

            MoneyText(amount)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .font(.caption)
        .accessibilityElement(children: .combine)
    }
}
