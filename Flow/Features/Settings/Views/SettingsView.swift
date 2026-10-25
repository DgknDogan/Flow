import SwiftUI

struct SettingsView: View {

    var body: some View {
        List {
            AccountSection()
            PreferencesSection()
            AppSettingsSection()
            SupportSection()
        }
        .listStyle(.insetGrouped)
        .localizedNavigationTitle("Settings")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
            .mainViewRoute()
    }
    .previewEnvironment()
}
#endif
