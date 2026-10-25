import Foundation

/// Asistan aracının modele döndüğü özet. Bütün hesaplar burada yapılır; küçük model aritmetikte
/// güvenilir olmadığı için toplamlar, paylar ve değişim oranı hazır verilir.
nonisolated struct SpendingSummary {

    static let largestExpenseLimit = 5
    static let categoryLimit = 8
    private static let noteLimit = 40

    /// Kategori filtresi: işlem türü ve kayıtlı ham değer.
    struct CategoryFilter: Equatable {
        let kind: TransactionKind
        let rawValue: String
    }

    let interval: DateInterval
    let previousInterval: DateInterval?
    let filter: CategoryFilter?

    let totalIncome: Decimal
    let totalExpense: Decimal
    let incomeCount: Int
    let expenseCount: Int
    /// Önceki dönemin gider toplamı; önceki dönem yoksa `nil`.
    let previousTotalExpense: Decimal?
    /// Kategori süzülünce dönemdeki tüm kategorilerin toplamı (filtre gider ise gider, gelir ise
    /// gelir); filtre yoksa `nil`. Model süzülmüş toplamı genel toplam sanıp "%100" demesin diye.
    let unfilteredTotal: Decimal?

    let expenseCategories: [CategoryShare<ExpenseCategory>]
    let incomeCategories: [CategoryShare<IncomeCategory>]
    /// Tutara göre en büyük giderler; eşit tutarlarda yeni olan önce.
    let largestExpenses: [Transaction]

    init(transactions: [Transaction], interval: DateInterval, previousInterval: DateInterval?, filter: CategoryFilter?) {
        self.interval = interval
        self.previousInterval = previousInterval
        self.filter = filter

        let matching = transactions.filter { transaction in
            guard let filter else { return true }
            return transaction.kind == filter.kind && transaction.category == filter.rawValue
        }
        let inPeriod = matching.filter { interval.containsHalfOpen($0.date) }
        unfilteredTotal = filter.map { filter in
            transactions
                .filter { $0.kind == filter.kind && interval.containsHalfOpen($0.date) }
                .reduce(0) { $0 + $1.amount }
        }

        var income: Decimal = 0
        var expense: Decimal = 0
        var incomeCount = 0
        var expenseCount = 0
        var expenseTotals: [ExpenseCategory: CategoryTotal] = [:]
        var incomeTotals: [IncomeCategory: CategoryTotal] = [:]

        for transaction in inPeriod {
            switch transaction.transactionType {
            case .income(let category):
                income += transaction.amount
                incomeCount += 1
                incomeTotals[category, default: CategoryTotal()].add(transaction.amount)
            case .expense(let category):
                expense += transaction.amount
                expenseCount += 1
                expenseTotals[category, default: CategoryTotal()].add(transaction.amount)
            }
        }

        totalIncome = income
        totalExpense = expense
        self.incomeCount = incomeCount
        self.expenseCount = expenseCount
        expenseCategories = CategoryShare.shares(from: expenseTotals)
        incomeCategories = CategoryShare.shares(from: incomeTotals)
        largestExpenses = Array(
            inPeriod
                .filter { $0.kind == .expense }
                .sorted { $0.amount == $1.amount ? $0.date > $1.date : $0.amount > $1.amount }
                .prefix(Self.largestExpenseLimit)
        )
        previousTotalExpense = previousInterval.map { previous in
            matching
                .filter { $0.kind == .expense && previous.containsHalfOpen($0.date) }
                .reduce(0) { $0 + $1.amount }
        }
    }

    var isEmpty: Bool {
        incomeCount + expenseCount == 0
    }

    /// Önceki döneme göre giderdeki değişim (0.12 = %12 artış); önceki dönemde gider yoksa `nil`.
    var expenseChange: Double? {
        guard let previousTotalExpense, previousTotalExpense > 0 else { return nil }
        return ((totalExpense - previousTotalExpense) / previousTotalExpense).doubleValue
    }

    /// Süzülen kategorinin dönemdeki tüm kategoriler içindeki payı (0.27 = %27); filtre yoksa `nil`.
    var filteredShare: Double? {
        guard let filter, let unfilteredTotal, unfilteredTotal > 0 else { return nil }
        let amount = filter.kind == .expense ? totalExpense : totalIncome
        return (amount / unfilteredTotal).doubleValue
    }

    // MARK: - Kategori eşleme

    /// Modelin verdiği kategori adını ham değerle ya da seçili dildeki görünen adla eşler;
    /// büyük/küçük harf ve aksan farkı yok sayılır. Gider kategorileri önce denenir.
    static func categoryFilter(matching name: String, locale: Locale) -> CategoryFilter? {
        let target = normalized(name)
        guard !target.isEmpty else { return nil }

        if let category = ExpenseCategory.allCases.first(where: { matches($0, target, locale) }) {
            return CategoryFilter(kind: .expense, rawValue: category.rawValue)
        }
        if let category = IncomeCategory.allCases.first(where: { matches($0, target, locale) }) {
            return CategoryFilter(kind: .income, rawValue: category.rawValue)
        }
        return nil
    }

    private static func matches(_ category: some CategoryProtocol, _ target: String, _ locale: Locale) -> Bool {
        normalized(category.rawValue) == target || normalized(category.displayName.localized(in: locale)) == target
    }

    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Modele giden metin

    /// Aracın çıktısı. Etiketler İngilizce (talimatlarla aynı dil); tutarlar ve kategori adları
    /// kullanıcının dilinde, modelin cevapta aynen kullanabilmesi için.
    func report(currency: Currency, locale: Locale, calendar: Calendar) -> String {
        let format = Decimal.FormatStyle.Currency.currency(currency).locale(locale)
        func money(_ amount: Decimal) -> String { amount.formatted(format) }

        var lines = ["Period: \(describe(interval, calendar: calendar))"]
        if let filter {
            lines.append("Category filter: \(categoryName(for: filter, locale: locale)). The totals below cover only this category.")
            if let unfilteredTotal {
                let kind = filter.kind == .expense ? "expenses" : "income"
                var line = "All \(kind) in this period, all categories: \(money(unfilteredTotal))"
                if let filteredShare {
                    line += "; this category's share: \(percent(filteredShare))"
                }
                lines.append(line)
            }
        }

        guard !isEmpty else {
            lines.append("No transactions recorded in this period.")
            appendPrevious(to: &lines, money: money, calendar: calendar)
            return lines.joined(separator: "\n")
        }

        lines.append("Total expenses: \(money(totalExpense)) (\(expenseCount) transactions)")
        lines.append("Total income: \(money(totalIncome)) (\(incomeCount) transactions)")
        lines.append("Net (income minus expenses): \(money(totalIncome - totalExpense))")
        appendPrevious(to: &lines, money: money, calendar: calendar)

        if !expenseCategories.isEmpty {
            let items = expenseCategories.prefix(Self.categoryLimit).map {
                "\($0.category.displayName.localized(in: locale)) \(money($0.amount)) (\(percent($0.share)), \($0.transactionCount) transactions)"
            }
            lines.append("Expenses by category: " + items.joined(separator: "; "))
        }
        if !incomeCategories.isEmpty {
            let items = incomeCategories.prefix(Self.categoryLimit).map {
                "\($0.category.displayName.localized(in: locale)) \(money($0.amount))"
            }
            lines.append("Income by category: " + items.joined(separator: "; "))
        }
        if !largestExpenses.isEmpty {
            let items = largestExpenses.map { transaction in
                var item = "\(day(transaction.date, calendar: calendar)) \(transaction.transactionType.details.displayName.localized(in: locale)) \(money(transaction.amount))"
                if let note = transaction.note?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty {
                    item += " \"\(note.prefix(Self.noteLimit))\""
                }
                return item
            }
            lines.append("Largest expenses: " + items.joined(separator: "; "))
        }
        return lines.joined(separator: "\n")
    }

    private func appendPrevious(to lines: inout [String], money: (Decimal) -> String, calendar: Calendar) {
        guard let previousInterval, let previousTotalExpense else { return }
        var line = "Previous period (\(describe(previousInterval, calendar: calendar))) expenses: \(money(previousTotalExpense))"
        if let expenseChange {
            line += ", change: \(expenseChange >= 0 ? "+" : "")\(percent(expenseChange))"
        }
        lines.append(line)
    }

    private func categoryName(for filter: CategoryFilter, locale: Locale) -> String {
        switch filter.kind {
        case .expense: (ExpenseCategory(rawValue: filter.rawValue) ?? .other).displayName.localized(in: locale)
        case .income: (IncomeCategory(rawValue: filter.rawValue) ?? .other).displayName.localized(in: locale)
        }
    }

    /// Bitiş dahil gün aralığı ("2026-03-01 to 2026-03-31"); tüm zamanlar için "all time".
    private func describe(_ interval: DateInterval, calendar: Calendar) -> String {
        guard interval.start != .distantPast else { return "all time" }
        let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
        let start = day(interval.start, calendar: calendar)
        let end = day(lastDay, calendar: calendar)
        return start == end ? start : "\(start) to \(end)"
    }

    private func day(_ date: Date, calendar: Calendar) -> String {
        date.formatted(Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day())
    }

    private func percent(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(0)).locale(Locale(identifier: "en_US_POSIX")))
    }
}
