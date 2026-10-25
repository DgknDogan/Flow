import SwiftUI

struct ChartSectionView: View {

    let report: PeriodReport

    @Environment(AppState.self) private var appState

    @State private var selectedDate: Date?

    private var range: DateTabs {
        report.range
    }

    private var selectedChartItem: ChartItem? {
        guard let selectedDate else { return nil }
        let item = report.chartData.first {
            Calendar.current.isDate(selectedDate, equalTo: $0.date, toGranularity: range.chartUnit)
        }
        guard let item, item.amount > 0 else { return nil }
        return item
    }

    /// Gün çubuklarında günlük limit; ay çubuklarında günlük limit × içinde bulunulan ayın
    /// gün sayısı (aylık limit) çizilir.
    private var chartLimit: Double? {
        guard let dailyLimit = appState.dailySpendingLimit else { return nil }
        switch range.chartUnit {
        case .day: return dailyLimit
        default: return dailyLimit * Double(Date.daysInCurrentMonth)
        }
    }

    /// Ortalama çizgisi yalnızca harcama varken çizilir.
    private var average: Double? {
        report.totalExpense > 0 ? report.averageExpense.doubleValue : nil
    }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                // Seçim yapılınca "Total spent" yerine seçilen gün/ayın bilgisi gösterilir.
                // Aynı Text'ler kullanıldığı için değişim numericText geçişiyle animasyonlu olur.
                VStack(alignment: .leading, spacing: 0) {
                    headerTitle
                        .contentTransition(.numericText())

                    MoneyText(selectedChartItem.map { Decimal(currencyAmount: $0.amount) } ?? report.totalExpense)
                        .font(.footnote.weight(selectedChartItem == nil ? .regular : .semibold))
                        .foregroundStyle(selectedChartItem == nil ? Color.secondary : Color.pink)
                        .contentTransition(.numericText())
                }
                .opacity(report.totalExpense == 0 && selectedChartItem == nil ? 0 : 1)
                .animation(.snappy, value: selectedChartItem)
                .frame(minHeight: 40, alignment: .topLeading)

                SpendingChart(
                    chartData: report.chartData,
                    range: range,
                    limit: chartLimit,
                    average: average,
                    selectedItem: selectedChartItem,
                    selectedDate: $selectedDate
                )

                ChartLegend(range: range, average: average, limit: chartLimit)
            }
        } header: {
            Text(range.chartTitle)
        }
        .listSectionSpacing(20)
    }

    /// Tek bir `Text` değeri döner ki seçim değişince numericText geçişi korunabilsin.
    private var headerTitle: Text {
        guard let selectedChartItem else { return Text("Total spent") }
        return Text(selectedChartItem.date, format: range.slotDateFormat)
    }
}
