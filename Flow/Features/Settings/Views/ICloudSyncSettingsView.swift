import SwiftUI
import Combine

struct ICloudSyncSettingsView: View {

    @Environment(AppState.self) private var appState

    @State private var isICloudAccountAvailable = FileManager.default.ubiquityIdentityToken != nil

    var body: some View {
        @Bindable var appState = appState

        List {
            Section {
                SettingsToggleRow(
                    icon: "icloud.fill",
                    tint: .cyan,
                    title: "iCloud Sync",
                    subtitle: "Keep transactions on all your devices",
                    isOn: $appState.isICloudSyncOn
                )
            } footer: {
                Text("Your transactions are stored in your private iCloud database. Only you can see them, and they come back if you reinstall Flow.")
            }

            if appState.needsRestartForSync {
                Section {
                    IconRow(
                        icon: "arrow.clockwise",
                        tint: .orange,
                        title: "Restart Required",
                        subtitle: appState.isICloudSyncOn
                            ? "Close and reopen Flow to turn on syncing."
                            : "Close and reopen Flow to turn off syncing."
                    )
                }
                .transition(.opacity)
            }

            if appState.isICloudSyncOn && !isICloudAccountAvailable {
                Section {
                    IconRow(
                        icon: "exclamationmark.icloud.fill",
                        tint: .red,
                        title: "iCloud Unavailable",
                        subtitle: "Sign in to iCloud in the Settings app. Your data stays on this device until then."
                    )
                }
                .transition(.opacity)
            }

            if appState.isICloudSyncOn && appState.isICloudStorageFull {
                Section {
                    IconRow(
                        icon: "externaldrive.fill.badge.exclamationmark",
                        tint: .orange,
                        title: "iCloud Storage Full",
                        subtitle: "New transactions are saved only on this device. They'll upload automatically once you free up iCloud storage."
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(AppAnimation.sectionToggle, value: appState.isICloudSyncOn)
        .animation(AppAnimation.sectionToggle, value: appState.isICloudStorageFull)
        .insetGroupedScreen("iCloud Sync")
        .onReceive(
            NotificationCenter.default.publisher(for: .NSUbiquityIdentityDidChange).receive(on: RunLoop.main)
        ) { _ in
            isICloudAccountAvailable = FileManager.default.ubiquityIdentityToken != nil
        }
    }
}

#Preview {
    NavigationStack {
        ICloudSyncSettingsView()
            .environment(AppState())
    }
}
