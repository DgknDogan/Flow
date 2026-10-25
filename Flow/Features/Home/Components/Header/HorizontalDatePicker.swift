import SwiftUI

struct HorizontalDatePicker: View {

    @Binding var selectedDay: Date
    @Binding var selectedMonth: Int
    let year: Int

    @Namespace private var selectionNamespace

    private var days: [Date] {
        Date.daysInMonth(month: selectedMonth, year: year)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(days, id: \.self) { day in
                        DayChip(
                            day: day,
                            isSelected: Calendar.current.isDate(selectedDay, inSameDayAs: day),
                            namespace: selectionNamespace
                        ) {
                            select(day)
                        }
                        .id(day)
                    }
                }
            }
            .padding(.vertical, 8)
            .scrollIndicators(.never)
            .onAppear {
                scrollToToday(with: proxy)
            }
            .onChange(of: selectedMonth) {
                selectMatchingDay(with: proxy)
            }
        }
    }

    private func select(_ day: Date) {
        guard selectedDay != day else { return }
        withAnimation(AppAnimation.selection) {
            selectedDay = day
        }
    }

    private func scrollToToday(with proxy: ScrollViewProxy) {
        if let today = days.first(where: { Calendar.current.isDateInToday($0) }) {
            proxy.scrollTo(today, anchor: .center)
        }
    }

    /// Ay değişince aynı gün numarasını (yoksa ayın ilk gününü) seçer ve ona kaydırır.
    private func selectMatchingDay(with proxy: ScrollViewProxy) {
        guard let firstDay = days.first else { return }
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: selectedDay)
        let matched = days.first { calendar.component(.day, from: $0) == currentDay } ?? firstDay

        withAnimation(AppAnimation.selection) {
            selectedDay = matched
            proxy.scrollTo(matched, anchor: .center)
        }
    }
}
