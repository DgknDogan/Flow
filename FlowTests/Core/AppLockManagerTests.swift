import Testing
import LocalAuthentication
@testable import Flow

@Suite("AppLockManager")
@MainActor
struct AppLockManagerTests {

    private let authenticator = FakeDeviceAuthenticator()

    @Test func startsLockedOnlyWhenEnabled() {
        #expect(AppLockManager(isEnabled: true, authenticator: authenticator).isLocked)
        #expect(!AppLockManager(isEnabled: false, authenticator: authenticator).isLocked)
    }

    @Test func biometryTypeComesFromAuthenticator() {
        authenticator.biometryType = .touchID
        #expect(AppLockManager(isEnabled: true, authenticator: authenticator).biometryType == .touchID)
    }

    @Test func lockLocksAnUnlockedApp() {
        let manager = AppLockManager(isEnabled: false, authenticator: authenticator)
        manager.lock()
        #expect(manager.isLocked)
    }

    @Test func successfulAuthenticationUnlocks() async {
        let manager = AppLockManager(isEnabled: true, authenticator: authenticator)

        await manager.unlock()

        #expect(!manager.isLocked)
        #expect(!manager.isAuthenticating)
        #expect(authenticator.promptCount == 1)
        #expect(authenticator.lastReason?.isEmpty == false)
    }

    @Test func failedAuthenticationStaysLocked() async {
        authenticator.result = false
        let manager = AppLockManager(isEnabled: true, authenticator: authenticator)

        await manager.unlock()

        #expect(manager.isLocked)
        #expect(!manager.isAuthenticating)
    }

    /// Cihaz parolası kaldırılırsa kullanıcı kalıcı olarak dışarıda kalmamalı.
    @Test func unlocksWithoutPromptWhenDeviceCannotAuthenticate() async {
        authenticator.canAuthenticate = false
        let manager = AppLockManager(isEnabled: true, authenticator: authenticator)

        await manager.unlock()

        #expect(!manager.isLocked)
        #expect(authenticator.promptCount == 0)
    }

    @Test func unlockDoesNothingWhenAlreadyUnlocked() async {
        let manager = AppLockManager(isEnabled: false, authenticator: authenticator)

        await manager.unlock()

        #expect(authenticator.promptCount == 0)
    }

    /// İptal edilen istem, uygulama tekrar aktif olunca yeniden sorulmamalı (döngü olmasın).
    @Test func automaticPromptHappensOncePerLock() async {
        authenticator.result = false
        let manager = AppLockManager(isEnabled: true, authenticator: authenticator)

        await manager.unlockAutomaticallyIfNeeded()
        await manager.unlockAutomaticallyIfNeeded()
        #expect(authenticator.promptCount == 1)

        manager.lock()
        await manager.unlockAutomaticallyIfNeeded()
        #expect(authenticator.promptCount == 2)
    }

    @Test func manualUnlockStillPromptsAfterAutomaticPrompt() async {
        authenticator.result = false
        let manager = AppLockManager(isEnabled: true, authenticator: authenticator)
        await manager.unlockAutomaticallyIfNeeded()

        authenticator.result = true
        await manager.unlock()

        #expect(!manager.isLocked)
        #expect(authenticator.promptCount == 2)
    }
}
