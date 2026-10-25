#if DEBUG
import Foundation
import SwiftData

/// UI testlerinin başlatma argümanları. Bu modda uygulama gerçek tercihlere ve veritabanına
/// dokunmaz: tercihler her açılışta boşaltılan ayrı bir suite'e, işlemler bellek içi depoya yazılır.
/// Argüman adları `FlowUITests/Support/LaunchArgument.swift` ile aynı olmalı.
enum UITestLaunch {

    static let enabledArgument = "-ui-testing"
    static let seedTransactionsArgument = "-ui-testing-seed"
    static let skipOnboardingArgument = "-ui-testing-skip-onboarding"

    private static let defaultsSuiteName = "com.dogukan.Flow.ui-testing"

    static var isEnabled: Bool {
        arguments.contains(enabledArgument)
    }

    /// Tercihleri boş bir depoya yönlendirir ve testin başlangıç durumunu yazar.
    static func prepareDefaults() {
        guard let store = UserDefaults(suiteName: defaultsSuiteName) else { return }
        store.removePersistentDomain(forName: defaultsSuiteName)
        UserDefaults.appStore = store
        UserDefaults.isICloudSyncOn = false
        UserDefaults.hasSeenAppIntroduction = arguments.contains(skipOnboardingArgument)
    }

    /// İstenirse bugüne tarihli örnek işlemlerle (`Transaction.samples`) dolu bellek içi depo.
    static func makeModelContainer() -> ModelContainer {
        .preview(arguments.contains(seedTransactionsArgument) ? Transaction.samples : [])
    }

    private static var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }
}
#endif
