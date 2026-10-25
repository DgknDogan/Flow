import SwiftUI

/// Hiç işlem yokken gösterilir; ekleme sheet'ini açan bir buton içerir.
struct EmptyStateView: View {

    let action: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize = 96.0

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "tray.fill")
                .font(.system(size: badgeSize * 0.4, weight: .semibold))
                .foregroundStyle(Color.accentColor.gradient)
                .frame(width: badgeSize, height: badgeSize)
                .background(Color.accentColor.opacity(0.12), in: .circle)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No Transactions Yet")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                Text("Add your first transaction to start tracking your spending.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            PrimaryButton(action: action) {
                Label("Add Transaction", systemImage: "plus.circle.fill")
            }
            .frame(maxWidth: 280)
            .accessibilityIdentifier("emptyStateAddButton")
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView { }
}
