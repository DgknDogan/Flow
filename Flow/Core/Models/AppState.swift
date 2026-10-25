import UIKit

@Observable
final class AppState {

    var currency: Currency = UserDefaults.appCurrency {
        didSet { UserDefaults.appCurrency = currency }
    }

    var dailySpendingLimit: Double? = UserDefaults.dailySpendingLimit {
        didSet { UserDefaults.dailySpendingLimit = dailySpendingLimit }
    }

    var isNotificationsOn: Bool = UserDefaults.isNotificationsOn {
        didSet { UserDefaults.isNotificationsOn = isNotificationsOn }
    }

    var appTheme: AppTheme = UserDefaults.appTheme {
        didSet { UserDefaults.appTheme = appTheme }
    }

    var isBudgetAlertOn: Bool = UserDefaults.isBudgetAlertOn {
        didSet { UserDefaults.isBudgetAlertOn = isBudgetAlertOn }
    }

    var isDailyReminderOn: Bool = UserDefaults.isDailyReminderOn {
        didSet { UserDefaults.isDailyReminderOn = isDailyReminderOn }
    }

    var isWeeklyReminderOn: Bool = UserDefaults.isWeeklyReminderOn {
        didSet { UserDefaults.isWeeklyReminderOn = isWeeklyReminderOn }
    }

    var isBiometricLockOn: Bool = UserDefaults.isBiometricLockOn {
        didSet { UserDefaults.isBiometricLockOn = isBiometricLockOn }
    }

    var budgetWarningThreshold: Double = UserDefaults.budgetWarningThreshold {
        didSet { UserDefaults.budgetWarningThreshold = budgetWarningThreshold }
    }

    var userName: String = UserDefaults.userName {
        didSet { UserDefaults.userName = userName }
    }

    /// İlk açılışta bir kez yazılır; profil ekranındaki "Member since" bilgisi buradan gelir.
    let memberSince: Date

    var profileImage: UIImage? = ProfileImageStore.load()

    var isICloudSyncOn: Bool = UserDefaults.isICloudSyncOn {
        didSet { UserDefaults.isICloudSyncOn = isICloudSyncOn }
    }

    /// ModelContainer açılışta bu değerle kuruldu; tercih farklıysa yeniden başlatma gerekir.
    let isICloudSyncActive: Bool = UserDefaults.isICloudSyncOn

    var needsRestartForSync: Bool {
        isICloudSyncOn != isICloudSyncActive
    }

    /// Kökte `\.locale` olarak uygulanır; değişince arayüz yeniden açmadan yeni dile geçer.
    var appLanguage: AppLanguage = UserDefaults.appLanguage {
        didSet { UserDefaults.appLanguage = appLanguage }
    }

    /// Son iCloud gönderimi depolama alanı dolu olduğu için başarısız oldu. Kalıcı değildir:
    /// açılışta bilinmez, bir sonraki gönderimin sonucuyla güncellenir.
    var isICloudStorageFull = false

    init() {
        if let memberSince = UserDefaults.memberSince {
            self.memberSince = memberSince
        } else {
            memberSince = .now
            UserDefaults.memberSince = memberSince
        }
    }
}
