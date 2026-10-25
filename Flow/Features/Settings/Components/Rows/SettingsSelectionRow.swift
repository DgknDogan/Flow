import SwiftUI

struct SettingsSelectionRow<Leading: View>: View {

    let title: LocalizedStringResource
    let isSelected: Bool
    let showsDivider: Bool
    let namespace: Namespace.ID
    @ViewBuilder let leading: Leading

    var body: some View {
        HStack(spacing: 14) {
            leading

            HStack {
                Text(title)
                    .foregroundStyle(Color.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.green)
                        .matchedGeometryEffect(id: "checkmark", in: namespace)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: 60)
            .overlay(alignment: .bottom) {
                if showsDivider {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .contentShape(.rect)
    }
}
