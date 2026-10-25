import SwiftUI

/// Düzenleme formunun üstünde hangi işlemin düzenlendiğini gösterir.
struct EditingBadge: View {

    let transaction: Transaction

    var body: some View {
        HStack(spacing: 10) {
            IconTile(systemName: "pencil", tint: .orange, size: 28, shape: .circle, font: .subheadline.bold())

            VStack(alignment: .leading, spacing: 0) {
                Text("Editing Transaction")
                    .font(.subheadline.weight(.semibold))
                Text(transaction.transactionType.details.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            MoneyText(transaction.amount)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.orange.opacity(0.12), in: .rect(cornerRadius: AppRadius.badge))
        .accessibilityElement(children: .combine)
    }
}
