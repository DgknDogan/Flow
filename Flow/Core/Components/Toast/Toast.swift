import Foundation

struct Toast: Identifiable, Equatable {
    let id = UUID()
    /// Simge ve rengi belirler.
    let kind: ToastKind
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    var duration: TimeInterval = 3

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Factory Methods

extension Toast {
    static func success(title: LocalizedStringResource, message: LocalizedStringResource) -> Toast {
        Toast(kind: .success, title: title, message: message)
    }

    static func error(title: LocalizedStringResource, message: LocalizedStringResource) -> Toast {
        Toast(kind: .error, title: title, message: message)
    }

    static func warning(title: LocalizedStringResource, message: LocalizedStringResource) -> Toast {
        Toast(kind: .warning, title: title, message: message)
    }

    static func info(title: LocalizedStringResource, message: LocalizedStringResource) -> Toast {
        Toast(kind: .info, title: title, message: message)
    }
}
