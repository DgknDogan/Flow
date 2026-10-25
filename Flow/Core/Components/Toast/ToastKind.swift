import SwiftUI

enum ToastKind {
    case success, error, warning, info

    var symbol: String {
        switch self {
        case .success: "checkmark.seal.fill"
        case .error: "xmark.seal.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .success: .green
        case .error: .red
        case .warning: .orange
        case .info: .blue
        }
    }
}
