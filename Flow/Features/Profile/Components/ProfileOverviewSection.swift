import SwiftUI

struct ProfileOverviewSection: View {

    let stats: ProfileStats

    var body: some View {
        Section("Overview") {
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    StatTile(icon: "list.bullet.rectangle.fill", tint: .indigo, title: "Transactions") {
                        Text(stats.transactionCount, format: .number)
                    }
                    StatTile(icon: "calendar", tint: .orange, title: "Active Days") {
                        Text(stats.activeDays, format: .number)
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
}
