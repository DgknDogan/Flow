import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.locale) private var locale

    private let authenticator = DeviceAuthenticator()

    var body: some View {
        @Bindable var appState = appState
        let biometryType = authenticator.biometryType
        let canAuthenticate = authenticator.canAuthenticate

        List {
            Section {
                SettingsToggleRow(
                    icon: biometryType.systemImage,
                    tint: .blue,
                    title: biometryType.displayName.map { LocalizedStringKey($0) } ?? "App Lock",
                    subtitle: "Require authentication to open the app",
                    isOn: $appState.isBiometricLockOn
                )
                .disabled(!canAuthenticate && !appState.isBiometricLockOn)
            } header: {
                Text("App Lock")
            } footer: {
                Text(footer(for: biometryType, canAuthenticate: canAuthenticate))
            }
        }
        .insetGroupedScreen("Security")
        .onChange(of: appState.isBiometricLockOn) { _, isOn in
            if isOn {
                confirmEnablingLock()
            }
        }
    }

    /// Kilit açılmadan önce kullanıcının gerçekten doğrulama yapabildiği teyit edilir; iptal ederse kapanır.
    private func confirmEnablingLock() {
        Task {
            let confirmed = await authenticator.authenticate(reason: LocalizedStringResource("Confirm to turn on App Lock.").localized(in: locale))
            if !confirmed {
                appState.isBiometricLockOn = false
            }
        }
    }

    private func footer(for biometryType: LABiometryType, canAuthenticate: Bool) -> LocalizedStringKey {
        guard canAuthenticate else {
            return "Set a passcode in the Settings app to use App Lock."
        }
        if let name = biometryType.displayName {
            return "Use \(name) to keep your financial data private. Your device passcode works as a fallback."
        }
        return "Use your device passcode to keep your financial data private."
    }
}

#Preview {
    NavigationStack {
        SecuritySettingsView()
            .environment(AppState())
    }
}
