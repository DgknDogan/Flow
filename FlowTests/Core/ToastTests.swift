import Testing
import SwiftUI
@testable import Flow

@Suite("Toast")
@MainActor
struct ToastTests {

    private let kinds: [ToastKind] = [.success, .error, .warning, .info]

    @Test func eachKindHasItsOwnSymbolAndColor() {
        #expect(Set(kinds.map(\.symbol)).count == kinds.count)
        #expect(Set(kinds.map(\.tint)).count == kinds.count)
    }

    @Test func symbolsExistInSFSymbols() {
        for kind in kinds {
            #expect(UIImage(systemName: kind.symbol) != nil, "Eksik SF Symbol: \(kind.symbol)")
        }
    }

    @Test func factoriesSetKindAndDefaultDuration() {
        #expect(Toast.success(title: "a", message: "b").kind == .success)
        #expect(Toast.error(title: "a", message: "b").kind == .error)
        #expect(Toast.warning(title: "a", message: "b").kind == .warning)
        #expect(Toast.info(title: "a", message: "b").kind == .info)
        #expect(Toast.info(title: "a", message: "b").duration == 3)
    }

    /// Aynı içerikli iki toast farklıdır; böylece aynı mesaj art arda gösterilebilir.
    @Test func toastsAreComparedByIdentity() {
        #expect(AppToasts.transactionAdded != AppToasts.transactionAdded)
    }

    /// `AppToasts` ana aktöre bağlı olduğu için parametreli test argümanı olamıyor; döngüyle kontrol ediliyor.
    @Test func appToastsUseTheRightKind() {
        let expectations: [(Toast, ToastKind)] = [
            (AppToasts.transactionAdded, .success),
            (AppToasts.transactionUpdated, .success),
            (AppToasts.profileUpdated, .success),
            (AppToasts.transactionError, .error),
            (AppToasts.transactionDeleteError, .error),
            (AppToasts.reminderError, .error),
            (AppToasts.profilePhotoError, .error),
            (AppToasts.invalidAmount, .warning),
            (AppToasts.supportEmailCopied, .info)
        ]

        for (toast, kind) in expectations {
            #expect(toast.kind == kind)
            #expect(!String(localized: toast.title).isEmpty)
            #expect(!String(localized: toast.message).isEmpty)
        }
    }
}
