import SwiftUI

struct AppSettingsSection: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        Section("App") {
            SettingsLinkRow(
                route: .appearance,
                icon: "paintbrush.fill",
                tint: .pink,
                title: "Appearance",
                detail: Text(appState.appTheme.title)
            )

            SettingsLinkRow(
                route: .language,
                icon: "globe",
                tint: .purple,
                title: "Language",
                detail: Text(appState.appLanguage.title)
            )

            SettingsLinkRow(
                route: .security,
                icon: "lock.fill",
                tint: .blue,
                title: "Security",
                detail: Text(isOn: appState.isBiometricLockOn)
            )

            SettingsLinkRow(
                route: .iCloudSync,
                icon: "icloud.fill",
                tint: .cyan,
                title: "iCloud Sync",
                detail: iCloudDetail
            )
        }
    }

    private var iCloudDetail: Text {
        appState.isICloudSyncOn && appState.isICloudStorageFull
            ? Text("Storage Full")
            : Text(isOn: appState.isICloudSyncOn)
    }
}
