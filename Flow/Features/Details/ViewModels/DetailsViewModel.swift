import Foundation
import Observation

/// Details sekmesinin durumu: dönem türü (hafta/ay/yıl), gösterilen dönem ve o dönemin raporu.
@Observable
final class DetailsViewModel {

    var dateSelection: DateTabs = .month {
        didSet { dateSelectionChanged(wasShowingCurrentPeriod: report.isCurrentPeriod) }
    }

    /// Gösterilen dönemin içindeki bir tarih; ileri/geri gezinme bunu kaydırır.
    private(set) var periodAnchor: Date
    private(set) var report: PeriodReport

    @ObservationIgnored private var transactions: [Transaction] = []
    private let calendar: Calendar
    private let now: () -> Date

    /// `now` testlerde sabit bir tarih vermek için enjekte edilebilir.
    init(calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.calendar = calendar
        self.now = now
        let today = now()
        periodAnchor = today
        report = PeriodReport(
            transactions: [],
            range: .month,
            interval: DateTabs.month.interval(containing: today, calendar: calendar),
            now: today,
            calendar: calendar
        )
    }

    var chartUnit: Calendar.Component {
        dateSelection.chartUnit
    }

    func periodTitle(locale: Locale) -> String {
        dateSelection.title(for: report.interval, locale: locale)
    }

    var isShowingCurrentPeriod: Bool {
        report.isCurrentPeriod
    }

    /// Gelecek dönemlerde veri olmayacağı için içinde bulunulan dönemden ileri gidilmez.
    var canShowNextPeriod: Bool {
        report.interval.end <= now()
    }

    /// Boş dönem dışa aktarılmaz.
    var canExport: Bool {
        report.transactionCount > 0
    }

    /// Gösterilen dönemin (hafta, ay ya da yıl) işlemleri CSV olarak.
    func csvExport(currencyCode: String, locale: Locale) -> PeriodCSV {
        PeriodCSV(
            transactions: transactions,
            range: dateSelection,
            interval: report.interval,
            currencyCode: currencyCode,
            locale: locale,
            calendar: calendar
        )
    }

    func updateTransactions(_ transactions: [Transaction]) {
        self.transactions = transactions
        refreshReport()
    }

    func showPreviousPeriod() {
        movePeriod(by: -1)
    }

    func showNextPeriod() {
        guard canShowNextPeriod else { return }
        movePeriod(by: 1)
    }

    func showCurrentPeriod() {
        periodAnchor = now()
        refreshReport()
    }

    private func movePeriod(by periods: Int) {
        periodAnchor = dateSelection.interval(shiftedBy: periods, from: report.interval, calendar: calendar).start
        refreshReport()
    }

    /// İçinde bulunulan dönem gösteriliyorsa yeni türde de bugünü içeren dönem açılır (bu aydan
    /// "Year"a geçince bu yıl); geçmiş bir dönemdeyken o dönemin başlangıcı korunur.
    private func dateSelectionChanged(wasShowingCurrentPeriod: Bool) {
        if wasShowingCurrentPeriod {
            periodAnchor = now()
        }
        refreshReport()
    }

    private func refreshReport() {
        report = PeriodReport(
            transactions: transactions,
            range: dateSelection,
            interval: dateSelection.interval(containing: periodAnchor, calendar: calendar),
            now: now(),
            calendar: calendar
        )
    }
}
