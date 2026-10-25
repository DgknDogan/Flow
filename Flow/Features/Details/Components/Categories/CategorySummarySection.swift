import SwiftUI

/// Kategori sayfasının üstü: büyük ikon, toplam, işlem sayısı ve işlem başına ortalama.
struct CategorySummarySection: View {

    let type: TransactionType
    let transactions: [Transaction]

    @Environment(AppState.self) private var appState

    var body: some View {
        let details = type.details
        let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
        let average = transactions.isEmpty ? 0 : total / Decimal(transactions.count)

        Section {
            VStack(spacing: 8) {
                IconTile(systemName: details.iconName, tint: details.color, size: 56, shape: .circle, font: .title2)

                MoneyText(total)
                    .font(.title.bold())
                    .contentTransition(.numericText())

                Text("^[\(transactions.count) transaction](inflect: true) · \(average, format: .currency(appState.currency)) average")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
        }
        .listRowBackground(Color.clear)
    }
}
