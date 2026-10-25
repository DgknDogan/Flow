import LocalAuthentication

nonisolated extension LABiometryType {

    /// Biyometri yoksa `nil`; bu durumda kilit cihaz parolasıyla açılır.
    var displayName: String? {
        switch self {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        default: nil
        }
    }

    var systemImage: String {
        switch self {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        default: "lock.fill"
        }
    }
}
