import Testing
import Foundation
@testable import Flow

@Suite("AppState")
@MainActor
struct AppStateTests {

    // Her test kendi izole deposunu gövdenin ilk satırında kurar; init ile gövde arasında
    // başka bir test global depoyu değiştiremesin.

    @Test func freshInstallUsesDefaults() {
        TestDefaults.installIsolatedStore()
        let state = AppState()

        #expect(state.currency == .dollar)
        #expect(state.appTheme == .system)
        #expect(state.dailySpendingLimit == nil)
        #expect(state.isNotificationsOn == false)
        #expect(state.isDailyReminderOn == false)
        #expect(state.isWeeklyReminderOn == false)
        #expect(state.isBiometricLockOn == false)
        #expect(state.isICloudSyncOn == true)
        #expect(!state.isICloudStorageFull, "Alan durumu bir gönderim bitene kadar bilinmez")
        #expect(state.userName.isEmpty)
    }

    @Test func changesArePersisted() {
        TestDefaults.installIsolatedStore()
        let state = AppState()
        state.currency = .turkishLira
        state.appTheme = .dark
        state.dailySpendingLimit = 75
        state.isNotificationsOn = true
        state.isDailyReminderOn = true
        state.isWeeklyReminderOn = true
        state.isBiometricLockOn = true
        state.userName = "Alex"

        let reloaded = AppState()
        #expect(reloaded.currency == .turkishLira)
        #expect(reloaded.appTheme == .dark)
        #expect(reloaded.dailySpendingLimit == 75)
        #expect(reloaded.isNotificationsOn)
        #expect(reloaded.isDailyReminderOn)
        #expect(reloaded.isWeeklyReminderOn)
        #expect(reloaded.isBiometricLockOn)
        #expect(reloaded.userName == "Alex")
    }

    @Test func memberSinceIsWrittenOnceAndKept() {
        TestDefaults.installIsolatedStore()
        let first = AppState()
        let second = AppState()

        #expect(first.memberSince == second.memberSince)
        #expect(UserDefaults.memberSince == first.memberSince)
    }

    /// Depo açılışta kurulduğu için senkronizasyon tercihi değişince yeniden başlatma gerekir.
    @Test func changingSyncPreferenceRequiresRestart() {
        TestDefaults.installIsolatedStore()
        let state = AppState()
        #expect(!state.needsRestartForSync)

        state.isICloudSyncOn.toggle()
        #expect(state.needsRestartForSync)
        #expect(state.isICloudSyncActive != state.isICloudSyncOn)

        state.isICloudSyncOn.toggle()
        #expect(!state.needsRestartForSync)
    }

    /// Seçim saklanır ve iOS'un çizdiği parçalar için `AppleLanguages`'a da yazılır.
    @Test func changingLanguageIsPersistedAndWritesAppleLanguages() {
        let store = TestDefaults.installIsolatedStore()
        let state = AppState()
        #expect(state.appLanguage == .system)

        state.appLanguage = .turkish
        #expect(store.stringArray(forKey: "AppleLanguages") == ["tr"])
        #expect(AppState().appLanguage == .turkish)
        #expect(state.appLanguage.locale.language.languageCode == .turkish)

        // Sisteme dönünce uygulamanın kendi kaydı silinir; değer artık cihazın genel ayarından gelir.
        state.appLanguage = .system
        #expect(store.stringArray(forKey: "AppleLanguages") != ["tr"])
    }

    /// iOS Ayarlar > Flow > Dil'den başka bir dil seçilirse uygulama içindeki eski seçim onu ezmez.
    @Test func languageChosenInSystemSettingsWins() {
        let store = TestDefaults.installIsolatedStore()
        UserDefaults.appLanguage = .turkish
        store.set(["fr-FR"], forKey: "AppleLanguages")

        #expect(UserDefaults.appLanguage == .system)
    }

    /// Görünüm dışı metinler (bildirim, Face ID istemi) seçili dilde çözülür.
    @Test func resourcesResolveInRequestedLanguage() {
        let resource: LocalizedStringResource = "Settings"

        #expect(resource.localized(in: AppLanguage.turkish.locale) == "Ayarlar")
        #expect(resource.localized(in: AppLanguage.french.locale) == "Réglages")
        #expect(resource.localized(in: AppLanguage.italian.locale) == "Impostazioni")
        #expect(resource.localized(in: AppLanguage.german.locale) == "Einstellungen")
        #expect(resource.localized(in: AppLanguage.english.locale) == "Settings")
    }
}
