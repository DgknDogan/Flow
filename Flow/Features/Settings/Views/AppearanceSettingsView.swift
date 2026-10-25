import SwiftUI

struct AppearanceSettingsView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        List {
            Section {
                SettingsSelectionGroup(selection: $appState.appTheme) { theme in
                    IconTile(systemName: theme.symbol, tint: theme.tint)
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose how Flow looks. System follows your device appearance.")
            }
        }
        .insetGroupedScreen("Appearance")
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
    .environment(AppState())
}
