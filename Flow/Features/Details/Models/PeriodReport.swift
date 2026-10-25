import Foundation

/// Seçilen dönemin (hafta, ay ya da yıl) özeti: toplamlar, grafik verisi, kategori dağılımı,
/// en büyük giderler ve önceki dönemle karşılaştırma. Saf hesaplama olduğu için "şimdi" ve
/// takvim dışarıdan verilir; görünümden bağımsız test edilir.
nonisolated struct PeriodReport: Equatable {

    static let largestExpenseLimit = 5

    let range: DateTabs
    let interval: DateInterval
    let isCurrentPeriod: Bool

    let totalIncome: Decimal
    let totalExpense: Decimal
    let transactionCount: Int
    /// Bir önceki dönemin gider toplamı.
    let previousTotalExpense: Decimal

    /// Grafik çubukları: haftalık ve aylık görünümde günler, yıllık görünümde aylar.
    /// Harcama olmayan dilimler 0'dır.
    let chartData: [ChartItem]
    /// Harcama yapılan günlerin gider toplamları (anahtar: günün başlangıcı).
    let dailyExpenses: [Date: Decimal]

    let expenseCategories: [CategoryShare<ExpenseCategory>]
    let incomeCategories: [CategoryShare<IncomeCategory>]
    /// Tutara göre en büyük giderler; eşit tutarlarda yeni olan önce.
    let largestExpenses: [Transaction]

    /// Dönemdeki gün sayısı.
    let dayCount: Int
    /// Bugüne kadar geçen gün sayısı (bugün dahil); geçmiş dönemlerde `dayCount`.
    let elapsedDayCount: Int
    /// Geçen günlerden harcama yapılanların sayısı.
    let elapsedSpendingDayCount: Int
    /// Geçen grafik dilimi (gün ya da ay) sayısı, içinde bulunulan dahil.
    let elapsedSlotCount: Int

    init(transactions: [Transaction], range: DateTabs, interval: DateInterval, now: Date, calendar: Calendar) {
        self.range = range
        self.interval = interval
        isCurrentPeriod = interval.containsHalfOpen(now)

        let inPeriod = transactions.filter { interval.containsHalfOpen($0.date) }
        transactionCount = inPeriod.count

        var income: Decimal = 0
        var expense: Decimal = 0
        var expenseTotals: [ExpenseCategory: CategoryTotal] = [:]
        var incomeTotals: [IncomeCategory: CategoryTotal] = [:]
        var daily: [Date: Decimal] = [:]

        for transaction in inPeriod {
            switch transaction.transactionType {
            case .income(let category):
                income += transaction.amount
                incomeTotals[category, default: CategoryTotal()].add(transaction.amount)
            case .expense(let category):
                expense += transaction.amount
                expenseTotals[category, default: CategoryTotal()].add(transaction.amount)
                daily[calendar.startOfDay(for: transaction.date), default: 0] += transaction.amount
            }
        }

        totalIncome = income
        totalExpense = expense
        dailyExpenses = daily
        expenseCategories = CategoryShare.shares(from: expenseTotals)
        incomeCategories = CategoryShare.shares(from: incomeTotals)
        largestExpenses = Array(
            inPeriod
                .filter { $0.kind == .expense }
                .sorted { $0.amount == $1.amount ? $0.date > $1.date : $0.amount > $1.amount }
                .prefix(Self.largestExpenseLimit)
        )

        let previousInterval = range.interval(shiftedBy: -1, from: interval, calendar: calendar)
        previousTotalExpense = transactions
            .filter { $0.kind == .expense && previousInterval.containsHalfOpen($0.date) }
            .reduce(0) { $0 + $1.amount }

        chartData = Self.chartItems(for: daily, unit: range.chartUnit, in: interval, calendar: calendar)
        elapsedSlotCount = chartData.count(where: { $0.date <= now })

        dayCount = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 0
        if now >= interval.end {
            elapsedDayCount = dayCount
        } else if now < interval.start {
            elapsedDayCount = 0
        } else {
            let today = calendar.startOfDay(for: now)
            elapsedDayCount = (calendar.dateComponents([.day], from: interval.start, to: today).day ?? 0) + 1
        }
        elapsedSpendingDayCount = daily.keys.count(where: { $0 <= now })
    }

    // MARK: - Türetilen değerler

    var isEmpty: Bool {
        transactionCount == 0
    }

    var netBalance: Decimal {
        totalIncome - totalExpense
    }

    /// Gelirin harcanmayan kısmı; gelir yoksa `nil`. Gider gelirden fazlaysa negatiftir.
    var savingsRate: Double? {
        guard totalIncome > 0 else { return nil }
        return (netBalance / totalIncome).doubleValue
    }

    /// Geçen dilim (gün ya da ay) başına ortalama gider.
    var averageExpense: Decimal {
        guard elapsedSlotCount > 0 else { return 0 }
        return totalExpense / Decimal(elapsedSlotCount)
    }

    /// Bu hızla dönem sonunda ulaşılacak gider; yalnızca devam eden dönemde ve harcama varken.
    var projectedExpense: Decimal? {
        guard isCurrentPeriod, totalExpense > 0, elapsedSlotCount < chartData.count else { return nil }
        return averageExpense * Decimal(chartData.count)
    }

    /// Önceki döneme göre giderdeki değişim (0.12 = %12 artış); önceki dönemde gider yoksa `nil`.
    var expenseChange: Double? {
        guard previousTotalExpense > 0 else { return nil }
        return ((totalExpense - previousTotalExpense) / previousTotalExpense).doubleValue
    }

    /// En çok harcanan gün ya da ay; eşitlikte ilki.
    var peak: ChartItem? {
        chartData.filter { $0.amount > 0 }.max { $0.amount < $1.amount }
    }

    /// Geçen günlerden hiç gider olmayanların sayısı.
    var noSpendDayCount: Int {
        max(elapsedDayCount - elapsedSpendingDayCount, 0)
    }

    /// Günlük limit girilmişse dönemin bütçe durumu.
    func budget(dailyLimit: Double?) -> BudgetSummary? {
        guard let dailyLimit, dailyLimit > 0 else { return nil }
        let limitPerDay = Decimal(currencyAmount: dailyLimit)
        let limit = limitPerDay * Decimal(dayCount)
        // Bugün de harcanabileceği için kalan günlere bugün dahildir.
        let remainingDays = isCurrentPeriod ? dayCount - elapsedDayCount + 1 : 0
        let remaining = limit - totalExpense

        return BudgetSummary(
            dailyLimit: limitPerDay,
            limit: limit,
            spent: totalExpense,
            daysOverLimit: dailyExpenses.values.count(where: { $0 > limitPerDay }),
            dailyAllowance: remainingDays > 0 && remaining > 0 ? remaining / Decimal(remainingDays) : nil
        )
    }

    // MARK: - Grafik

    /// Dönemdeki her dilim için bir çubuk; günlük toplamlar dilimlere (gün ya da ay) toplanır.
    private static func chartItems(
        for dailyExpenses: [Date: Decimal],
        unit: Calendar.Component,
        in interval: DateInterval,
        calendar: Calendar
    ) -> [ChartItem] {
        var totalsBySlot: [Date: Decimal] = [:]
        for (day, amount) in dailyExpenses {
            guard let slotStart = calendar.dateInterval(of: unit, for: day)?.start else { continue }
            totalsBySlot[slotStart, default: 0] += amount
        }

        var items: [ChartItem] = []
        var slotStart = interval.start
        while slotStart < interval.end {
            items.append(ChartItem(date: slotStart, amount: (totalsBySlot[slotStart] ?? 0).doubleValue))
            guard let next = calendar.date(byAdding: unit, value: 1, to: slotStart) else { break }
            slotStart = next
        }
        return items
    }
}
