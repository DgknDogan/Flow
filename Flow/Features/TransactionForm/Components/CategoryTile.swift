import SwiftUI

struct CategoryTile<Category: CategoryProtocol>: View {

    let category: Category
    let isSelected: Bool
    let namespace: Namespace.ID

    @ScaledMetric(relativeTo: .caption) private var iconSize = 24.0

    var body: some View {
        VStack {
            Image(systemName: category.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(category.color)
                .accessibilityHidden(true)

            Text(category.displayName)
                .font(.caption)
                .foregroundStyle(isSelected ? category.color : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(category.color.opacity(0.12))
                    .matchedGeometryEffect(id: "selection", in: namespace)
            } else {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(Color.gray.opacity(0.1).gradient)
            }
        }
        .contentShape(.rect)
    }
}
