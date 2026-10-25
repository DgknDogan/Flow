import Foundation

extension UserDefaults {

    /// Uygulama tercihlerinin yazıldığı depo. Varsayılan `.standard`; UI testleri ve birim testler
    /// gerçek tercihlere dokunmamak için kendi izole depolarını atar.
    @MainActor static var appStore: UserDefaults = .standard
}

extension UserDefaults {

    @UserDefaultsPW<Bool>(key: "isUserBoarded", defaultValue: false)
    static var hasSeenAppIntroduction: Bool
    
    // Anahtar eski adıyla kalır ki daha önce kaydedilmiş limit kaybolmasın.
    @UserDefaultsPW<Double?>(key: "maximumSpendingBudget")
    static var dailySpendingLimit: Double?
    
    @UserDefaultsPW<Bool>(key: "isNotificationsOn", defaultValue: false)
    static var isNotificationsOn: Bool
    
    @UserDefaultsRawPW<Currency>(key: "appCurrency", defaultValue: .dollar)
    static var appCurrency: Currency

    @UserDefaultsRawPW<AppTheme>(key: "appTheme", defaultValue: .system)
    static var appTheme: AppTheme

    @UserDefaultsPW<Bool>(key: "isBudgetAlertOn", defaultValue: true)
    static var isBudgetAlertOn: Bool

    @UserDefaultsPW<Bool>(key: "isDailyReminderOn", defaultValue: false)
    static var isDailyReminderOn: Bool

    @UserDefaultsPW<Bool>(key: "isWeeklyReminderOn", defaultValue: false)
    static var isWeeklyReminderOn: Bool

    @UserDefaultsPW<Bool>(key: "isBiometricLockOn", defaultValue: false)
    static var isBiometricLockOn: Bool

    @UserDefaultsPW<Double>(key: "budgetWarningThreshold", defaultValue: 0.8)
    static var budgetWarningThreshold: Double

    @UserDefaultsPW<String>(key: "userName", defaultValue: "")
    static var userName: String

    @UserDefaultsPW<Date?>(key: "memberSince")
    static var memberSince: Date?

    @UserDefaultsPW<Bool>(key: "isICloudSyncOn", defaultValue: true)
    static var isICloudSyncOn: Bool

    @UserDefaultsRawPW<AppLanguage>(key: "appLanguage", defaultValue: .system)
    private static var storedAppLanguage: AppLanguage

    /// Seçimi saklar ve iOS'un açılışta okuduğu `AppleLanguages` anahtarını günceller.
    /// `system` seçilince anahtar silinir; uygulama yeniden cihaz dilini izler.
    static var appLanguage: AppLanguage {
        get {
            // iOS Ayarlar > Flow > Dil de `AppleLanguages`'ı yazar. Oradan başka bir dil seçildiyse
            // uygulama içindeki eski seçim onu ezmesin; `system` iOS'un tercihini izler.
            let preferred = appStore.stringArray(forKey: "AppleLanguages")?.first
            guard let code = storedAppLanguage.languageCode,
                  let preferred,
                  Locale.Language(identifier: preferred).languageCode?.identifier != code
            else { return storedAppLanguage }
            return .system
        }
        set {
            storedAppLanguage = newValue
            if let code = newValue.languageCode {
                appStore.set([code], forKey: "AppleLanguages")
            } else {
                appStore.removeObject(forKey: "AppleLanguages")
            }
        }
    }

}
