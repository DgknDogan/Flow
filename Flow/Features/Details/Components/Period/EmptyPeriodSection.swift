import SwiftUI

/// Seçilen dönemde hiç işlem yokken gösterilir; dönem seçici üstte kalır.
struct EmptyPeriodSection: View {

    let periodTitle: String

    var body: some View {
        Section {
            ContentUnavailableView(
                "No Transactions",
                systemImage: "calendar.badge.exclamationmark",
                description: Text("Nothing was recorded in \(periodTitle).")
            )
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        EmptyPeriodSection(periodTitle: "September 2026")
    }
}
