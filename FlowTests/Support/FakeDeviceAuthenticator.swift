import LocalAuthentication
@testable import Flow

/// Face ID / parola isteminin sahtesi; sonucu ve kaç kez sorulduğunu test belirler.
@MainActor
final class FakeDeviceAuthenticator: DeviceAuthenticating {

    var canAuthenticate = true
    var biometryType: LABiometryType = .faceID
    var result = true
    private(set) var promptCount = 0
    private(set) var lastReason: String?

    func authenticate(reason: String) async -> Bool {
        promptCount += 1
        lastReason = reason
        return result
    }
}
