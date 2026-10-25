import SwiftUI

struct TransactionRowContent: View {

    private enum Layout {
        static let iconSize = 40.0
        static let rowPadding = 16.0
        static let contentSpacing = 8.0
        static let minRowHeight = 70.0
    }

    let transaction: Transaction
    let showsDivider: Bool

    var body: some View {
        let details = transaction.transactionType.details

        HStack(spacing: Layout.contentSpacing) {
            IconTile(systemName: details.iconName, tint: details.color, size: Layout.iconSize, shape: .circle, font: .body)

            VStack(alignment: .leading, spacing: 2) {
                Text(details.displayName)
                    .font(.headline)

                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // İşaret (+/−) gelir ile gideri renkten bağımsız ayırt ettirir.
            MoneyText(transaction.signedAmount, showsSign: true)
                .foregroundStyle(transaction.kind == .income ? .green : .red)
                .bold()
        }
        .padding(Layout.rowPadding)
        .frame(minHeight: Layout.minRowHeight)
        .contentShape(.rect)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider()
                    .padding(.leading, Layout.rowPadding + Layout.iconSize + Layout.contentSpacing)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
}
