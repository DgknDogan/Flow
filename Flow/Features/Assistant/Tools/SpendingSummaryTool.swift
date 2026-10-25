import Foundation
@preconcurrency import LiteRTLM
import Synchronization

/// Modelin kullanıcının harcamalarını sorduğu araç. LiteRT-LM aracı her çağrıda argümanlardan
/// yeniden oluşturduğu için veri kaynağı (container, para birimi, dil) örnekte tutulamaz; oturum
/// açılmadan önce `use(_:)` ile verilir. Parametreler property wrapper yerine düz `ToolParam` olarak yazılır;
/// `nonisolated` tiplerde property wrapper kullanılamıyor.
/// LiteRT-LM adları modele snake_case verir (`get_spending_summary`, `start_date`); talimatlar da öyle anar.
nonisolated struct SpendingSummaryTool: Tool {

    static let name = "getSpendingSummary"
    static let description = """
        Returns the user's real income and expense totals, spending by category, the largest \
        expenses and a comparison with the previous period. Call it for any question about the \
        user's own money.
        """

    private static let source = Mutex<SpendingReporter?>(nil)

    /// Sonraki çağrıların okuyacağı veri kaynağını ayarlar.
    static func use(_ reporter: SpendingReporter) {
        source.withLock { $0 = reporter }
    }

    var period = ToolParam<String?>(description: """
        The period the user asks about. One of: today, yesterday, thisWeek, lastWeek, thisMonth, \
        lastMonth, thisYear, lastYear, last7Days, last30Days, allTime, custom. Use custom only when \
        the user gives specific dates. Defaults to thisMonth.
        """)

    var startDate = ToolParam<String?>(description: "First day of a custom period, formatted yyyy-MM-dd.")

    var endDate = ToolParam<String?>(description: "Last day of a custom period (inclusive), formatted yyyy-MM-dd.")

    var category = ToolParam<String?>(description: """
        Optional category to filter by. Expense categories: Housing, Utilities, Dining Out, \
        Groceries, Transportation, Shopping, Health, Education, Travel, Subscriptions, \
        Entertainment, Other. Income categories: Salary, Freelance, Investment, Gift, \
        Rental Income, Bonus, Sales, Refunds. Leave empty for all categories.
        """)

    init() {}

    func run() async throws -> Any {
        try Self.report(
            period: period.wrappedValue,
            startDate: startDate.wrappedValue,
            endDate: endDate.wrappedValue,
            category: category.wrappedValue
        )
    }

    /// Modelin araç çağrısında ya da sızan araç metninde verdiği argümanlarla özet.
    static func report(period: String?, startDate: String?, endDate: String?, category: String?) throws -> String {
        guard let reporter = source.withLock({ $0 }) else {
            return "The user's transactions are not available right now."
        }
        return try reporter.report(
            period: period.flatMap(SpendingPeriod.init(name:)) ?? .thisMonth,
            startDate: startDate,
            endDate: endDate,
            category: category
        )
    }
}
