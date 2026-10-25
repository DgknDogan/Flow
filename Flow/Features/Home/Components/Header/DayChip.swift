import SwiftUI

struct DayChip: View {

    let day: Date
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(day, format: .dateTime.month(.abbreviated))
                Text(day, format: .dateTime.day())
            }
            .font(.headline)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal)
            .frame(minWidth: 80, minHeight: 60)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: AppRadius.tile)
                        .fill(Color.accentColor.gradient)
                        .matchedGeometryEffect(id: "selectedDay", in: namespace)
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.tile)
                        .fill(Color(.secondarySystemGroupedBackground))
                }
            }
        }
        .accessibilityLabel(Text(day, format: .dateTime.day().month(.wide)))
        .accessibilitySelected(isSelected)
    }
}
