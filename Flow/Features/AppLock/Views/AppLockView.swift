import SwiftUI
import LocalAuthentication

/// Uygulama kilitliyken tüm içeriğin üstünde gösterilir.
struct AppLockView: View {

    let biometryType: LABiometryType
    let isAuthenticating: Bool
    let onUnlock: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Flow is Locked", systemImage: "lock.fill")
        } description: {
            Text("Unlock to view your transactions.")
        } actions: {
            Button(unlockTitle, systemImage: biometryType.systemImage, action: onUnlock)
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }

    private var unlockTitle: LocalizedStringKey {
        if let name = biometryType.displayName {
            "Unlock with \(name)"
        } else {
            "Unlock with Passcode"
        }
    }
}

#Preview {
    AppLockView(biometryType: .faceID, isAuthenticating: false) { }
}
