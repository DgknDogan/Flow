import LocalAuthentication

/// Cihaz kimlik doğrulaması (Face ID / Touch ID / parola); testlerde sahtesiyle değiştirilir.
protocol DeviceAuthenticating {
    /// Cihazda parola (ve varsa biyometri) tanımlı mı.
    var canAuthenticate: Bool { get }
    var biometryType: LABiometryType { get }
    /// Biyometri yoksa ya da başarısız olursa cihaz parolasına düşer. İptal de `false` döner.
    func authenticate(reason: String) async -> Bool
}
