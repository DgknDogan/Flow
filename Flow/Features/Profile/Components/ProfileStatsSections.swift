import SwiftUI

/// Özet ve en çok harcanan kategori bölümleri; istatistikler tek seferde hesaplanır.
struct ProfileStatsSections: View {

    let transactions: [Transaction]

    var body: some View {
        let stats = ProfileStats(transactions: transactions)

        ProfileOverviewSection(stats: stats)

        if let topCategory = stats.topCategory {
            ProfileTopCategorySection(
                category: topCategory.category,
                amount: topCategory.amount,
                share: stats.topCategoryShare
            )
        }
    }
}
