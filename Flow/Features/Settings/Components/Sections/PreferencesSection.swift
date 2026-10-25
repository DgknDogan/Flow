import SwiftUI

struct PreferencesSection: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        Section("Preferences") {
            SettingsLinkRow(
                route: .notifications,
                icon: "bell.fill",
                tint: .orange,
                title: "Notifications",
                detail: Text(isOn: appState.isNotificationsOn)
            )

            SettingsLinkRow(
                route: .currency,
                icon: "banknote.fill",
                tint: .green,
                title: "Currency",
                detail: Text(verbatim: appState.currency.actualSymbol)
            )

            SettingsLinkRow(
                route: .budget,
                icon: "wallet.bifold.fill",
                tint: .indigo,
                title: "Daily Limit",
                detail: budgetDetail
            )
        }
    }

    private var budgetDetail: Text {
        guard let budget = appState.dailySpendingLimit else { return Text("Not set") }
        return Text("\(budget, format: .currency(appState.currency).precision(.fractionLength(0))) / day")
    }
}
