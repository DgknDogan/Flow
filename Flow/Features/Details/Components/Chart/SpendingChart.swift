import SwiftUI
import Charts

/// Dönemin tüm dilimlerini (günler ya da aylar) tek ekranda gösteren çubuk grafik.
/// Hafta, ay ve yıl aynı yapıda (kaydırmasız) çizildiği için aralarındaki geçiş animasyonludur;
/// aylık grafik kaydırılabilirken ay ile diğerleri arasındaki geçişte çubuklar kayboluyordu.
struct SpendingChart: View {

    let chartData: [ChartItem]
    let range: DateTabs
    let limit: Double?
    let average: Double?
    let selectedItem: ChartItem?

    @Binding var selectedDate: Date?

    private var chartUnit: Calendar.Component {
        range.chartUnit
    }

    var body: some View {
        Chart {
            if let limit {
                RuleMark(y: .value("Spending Limit", limit))
                    .foregroundStyle(.pink.gradient)
                    .lineStyle(StrokeStyle(dash: [5]))
            }

            if let average {
                RuleMark(y: .value("Average", average))
                    .foregroundStyle(Color.gray)
                    .lineStyle(StrokeStyle(dash: [2, 4]))
            }

            if let selectedItem {
                RuleMark(x: .value("Date", selectedItem.date, unit: chartUnit))
                    .foregroundStyle(.pink.gradient.opacity(0.4))
            }

            ForEach(chartData) { item in
                BarMark(
                    x: .value("Date", item.date, unit: chartUnit),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.pink.gradient)
                .cornerRadius(barCornerRadius)
                .opacity(selectedItem == nil || item.date == selectedItem?.date ? 1.0 : 0.4)
            }
        }
        .chartXSelection(value: $selectedDate)
        .animation(.easeInOut, value: selectedDate)
        .overlay {
            if chartData.allSatisfy({ $0.amount == 0 }) {
                ContentUnavailableView {
                    Label {
                        Text(range.emptyChartMessage)
                    } icon: {
                        Image(systemName: "chart.bar")
                    }
                }
            }
        }
        .frame(height: 300)
        .padding(.vertical)
        .chartXAxis {
            switch range {
            case .week:
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                }
            case .month:
                // Ayın her günü yazılırsa etiketler üst üste biner; haftada bir gün yazılır.
                // `centered` etiketi yedi günlük aralığın ortasına koyacağı için kullanılmaz.
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisValueLabel(format: .dateTime.day())
                }
            case .year:
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel(format: .dateTime.month(), centered: true)
                }
            }
        }
    }

    /// Aylık görünümde 28–31 ince çubuk olduğu için köşeler de küçülür.
    private var barCornerRadius: Double {
        range == .month ? AppRadius.icon / 2 : AppRadius.icon
    }
}
