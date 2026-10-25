import Testing
@testable import Flow

@Suite("ToastManager")
@MainActor
struct ToastManagerTests {

    private let manager = ToastManager()

    @Test func showPresentsTheToast() {
        let toast = AppToasts.transactionAdded

        manager.show(toast)

        #expect(manager.isPresented)
        #expect(manager.currentToast == toast)
    }

    @Test func dismissalRunsCallbackOnce() {
        var callCount = 0
        manager.show(AppToasts.profileUpdated) { callCount += 1 }

        manager.completeDismissal()
        manager.completeDismissal()

        #expect(callCount == 1)
    }

    /// Sheet kapanmadan toast gösterilmemeli; kapanınca bir kez gösterilmeli.
    @Test func pendingToastWaitsForSheetDismissal() {
        let toast = AppToasts.transactionUpdated

        manager.showAfterDismiss(toast)
        #expect(!manager.isPresented)
        #expect(manager.currentToast == nil)

        manager.showPendingToast()
        #expect(manager.isPresented)
        #expect(manager.currentToast == toast)

        manager.isPresented = false
        manager.showPendingToast()
        #expect(!manager.isPresented)
    }

    @Test func showingPendingWithoutOneDoesNothing() {
        manager.showPendingToast()

        #expect(!manager.isPresented)
        #expect(manager.currentToast == nil)
    }
}
