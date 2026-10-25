import Foundation
@testable import Flow

/// Testler için boş, izole tercih depoları. Gerçek `UserDefaults.standard`'a dokunulmaz.
@MainActor
enum TestDefaults {

    /// Yeni bir depo oluşturur ve `UserDefaults.appStore` olarak atar.
    @discardableResult
    static func installIsolatedStore() -> UserDefaults {
        let suiteName = "FlowTests.\(UUID().uuidString)"
        guard let store = UserDefaults(suiteName: suiteName) else {
            fatalError("Test için UserDefaults suite'i oluşturulamadı: \(suiteName)")
        }
        store.removePersistentDomain(forName: suiteName)
        UserDefaults.appStore = store
        return store
    }
}
