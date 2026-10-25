import SwiftUI

/// Bu ay dahil son 12 ayı kronolojik sırayla listeler; böylece geçen yılın ayları da seçilebilir.
struct MonthPickerList: View {

    @Binding var selectedMonth: Int
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Date.recentMonthStarts(), id: \.self) { monthStart in
                let month = Calendar.current.component(.month, from: monthStart)

                Button {
                    select(month)
                } label: {
                    HStack {
                        Text(monthStart, format: .dateTime.month(.wide).year())
                        Spacer()
                        if month == selectedMonth {
                            Image(systemName: "checkmark")
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(minHeight: AppLayout.minimumTapSize)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilitySelected(month == selectedMonth)
            }
        }
        .padding()
    }

    private func select(_ month: Int) {
        selectedMonth = month
        onSelect()
    }
}
