import SwiftUI

/// Profil ve Details özetlerindeki istatistik kutusu: ikon, değer ve başlık.
struct StatTile<Value: View>: View {

    let icon: String
    let tint: Color
    let title: LocalizedStringKey
    @ViewBuilder let value: Value

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                value
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: AppRadius.tile))
        .accessibilityElement(children: .combine)
    }
}
