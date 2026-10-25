import LocalAuthentication
import Observation

/// Uygulama kilidi: arka plana geçince kilitlenir, Face ID / Touch ID ya da cihaz parolasıyla açılır.
@Observable
final class AppLockManager {

    private(set) var isLocked: Bool
    private(set) var isAuthenticating = false
    let biometryType: LABiometryType

    /// Her kilitte yalnızca bir kez otomatik sorulur; iptal edilirse kullanıcı kilit ekranındaki
    /// butonla tekrar dener. Aksi halde istem kapanınca uygulama yeniden aktif olup döngüye girer.
    @ObservationIgnored private var didPromptForCurrentLock = false
    private let authenticator: any DeviceAuthenticating

    init(
        isEnabled: Bool = UserDefaults.isBiometricLockOn,
        authenticator: any DeviceAuthenticating = DeviceAuthenticator()
    ) {
        isLocked = isEnabled
        self.authenticator = authenticator
        biometryType = authenticator.biometryType
    }

    func lock() {
        isLocked = true
        didPromptForCurrentLock = false
    }

    func unlockAutomaticallyIfNeeded() async {
        guard isLocked, !didPromptForCurrentLock else { return }
        didPromptForCurrentLock = true
        await unlock()
    }

    func unlock() async {
        guard isLocked, !isAuthenticating else { return }

        // Cihaz parolası kaldırıldıysa doğrulama mümkün değil; kullanıcı kalıcı olarak dışarıda kalmasın.
        guard authenticator.canAuthenticate else {
            isLocked = false
            return
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        if await authenticator.authenticate(reason: LocalizedStringResource("Unlock Flow to view your finances.").localized(in: .app)) {
            isLocked = false
        }
    }
}
