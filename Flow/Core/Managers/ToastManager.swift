import SwiftUI

@Observable
final class ToastManager {
    var isPresented: Bool = false
    private(set) var currentToast: Toast? = nil
    @ObservationIgnored private var activeOnDismiss: (() -> Void)? = nil
    @ObservationIgnored private var pendingToast: Toast? = nil

    func show(_ toast: Toast, onDismiss: (() -> Void)? = nil) {
        currentToast = toast
        activeOnDismiss = onDismiss
        isPresented = true
    }

    func completeDismissal() {
        activeOnDismiss?()
        activeOnDismiss = nil
    }

    /// Toast'ı bir sheet kapandıktan sonra gösterilmek üzere bekletir; böylece sheet kapanışı ile
    /// toast animasyonu üst üste binmez. Sheet'in `onDismiss`'inde `showPendingToast()` çağrılmalı.
    func showAfterDismiss(_ toast: Toast) {
        pendingToast = toast
    }

    func showPendingToast() {
        guard let pendingToast else { return }
        self.pendingToast = nil
        show(pendingToast)
    }
}
