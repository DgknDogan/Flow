import SwiftUI

/// Dönemdeki tüm kategoriler; her satır o kategorinin işlemlerine götürür.
/// Gider dağılımında üstte halka grafik de gösterilir.
struct CategoryBreakdownSection<Category: CategoryProtocol>: View {

    let title: LocalizedStringKey
    let shares: [CategoryShare<Category>]
    let total: Decimal
    var showsChart = false
    /// Satırın açacağı kategori sayfası.
    let route: (Category) -> CategoryRoute

    var body: some View {
        Section {
            if showsChart {
                CategoryDonutChart(shares: shares, total: total)
            }

            ForEach(shares) { share in
                NavigationLink(value: route(share.category)) {
                    CategoryShareRow(share: share)
                }
            }
        } header: {
            Text(title)
        }
    }
}
