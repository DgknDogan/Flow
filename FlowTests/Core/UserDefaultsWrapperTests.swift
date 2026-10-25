import Testing
import Foundation
@testable import Flow

@Suite("UserDefaults wrappers")
@MainActor
struct UserDefaultsWrapperTests {

    @Test func missingValuesFallBackToDefaults() {
        TestDefaults.installIsolatedStore()
        #expect(UserDefaults.hasSeenAppIntroduction == false)
        #expect(UserDefaults.appCurrency == .dollar)
        #expect(UserDefaults.appTheme == .system)
        #expect(UserDefaults.dailySpendingLimit == nil)
        #expect(UserDefaults.isNotificationsOn == false)
        #expect(UserDefaults.isICloudSyncOn == true)
        #expect(UserDefaults.userName.isEmpty)
        #expect(UserDefaults.memberSince == nil)
    }

    @Test func writesGoToTheAppStore() {
        let store = TestDefaults.installIsolatedStore()
        UserDefaults.appCurrency = .euro
        UserDefaults.isBiometricLockOn = true
        UserDefaults.userName = "Alex"

        #expect(store.string(forKey: "appCurrency") == Currency.euro.rawValue)
        #expect(store.bool(forKey: "isBiometricLockOn"))
        #expect(store.string(forKey: "userName") == "Alex")
    }

    /// Daha önce kaydedilmiş limitler kaybolmasın diye eski anahtar adı korunuyor.
    @Test func dailyLimitUsesLegacyKey() {
        let store = TestDefaults.installIsolatedStore()
        UserDefaults.dailySpendingLimit = 50
        #expect(store.double(forKey: "maximumSpendingBudget") == 50)
    }

    @Test func assigningNilRemovesTheValue() {
        let store = TestDefaults.installIsolatedStore()
        UserDefaults.dailySpendingLimit = 50
        UserDefaults.dailySpendingLimit = nil

        #expect(store.object(forKey: "maximumSpendingBudget") == nil)
        #expect(UserDefaults.dailySpendingLimit == nil)
    }

    @Test func unknownRawValueFallsBackToDefault() {
        let store = TestDefaults.installIsolatedStore()
        store.set("sepia", forKey: "appTheme")
        #expect(UserDefaults.appTheme == .system)
    }

    @Test func valueOfWrongTypeFallsBackToDefault() {
        let store = TestDefaults.installIsolatedStore()
        store.set("yes", forKey: "isNotificationsOn")
        #expect(UserDefaults.isNotificationsOn == false)
    }
}
