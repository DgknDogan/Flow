import SwiftUI

struct CurrencySettingsView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        List {
            Section {
                SettingsSelectionGroup(selection: $appState.currency) { currency in
                    Text(verbatim: currency.actualSymbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 34, height: 34)
                        .background(Color.green.gradient, in: .rect(cornerRadius: AppRadius.icon))
                        .accessibilityHidden(true)
                }
            } footer: {
                Text("Your chosen currency is used across the app to format amounts.")
            }
        }
        .insetGroupedScreen("Currency")
    }
}

#Preview {
    NavigationStack {
        CurrencySettingsView()
    }
    .environment(AppState())
}
