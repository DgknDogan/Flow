import UserNotifications

/// Yerel bildirimler: sabah ve akşam birer günlük hatırlatma, pazartesi öğleden sonra bir haftalık hatırlatma.
nonisolated struct ReminderScheduler {

    /// Bir hatırlatmanın zamanı (yerel saatle) ve o saatte gösterilen metin.
    struct Reminder: Sendable {
        let identifier: String
        /// `nil` ise her gün; doluysa haftanın o günü (Gregoryen takvimde 1 = pazar, 2 = pazartesi).
        var weekday: Int? = nil
        let hour: Int
        let title: String.LocalizationValue
        let body: String.LocalizationValue

        var dateComponents: DateComponents {
            DateComponents(hour: hour, minute: 0, weekday: weekday)
        }
    }

    static let dailyReminders = [
        Reminder(
            identifier: "daily-reminder-9",
            hour: 9,
            title: "Good Morning",
            body: "Forgot to log something yesterday? Add it to Flow now."
        ),
        Reminder(
            identifier: "daily-reminder-21",
            hour: 21,
            title: "Daily Reminder",
            body: "Take a moment to log today's expenses in Flow."
        )
    ]

    static let weeklyReminder = Reminder(
        identifier: "weekly-reminder",
        weekday: 2,
        hour: 13,
        title: "Weekly Check-in",
        body: "A new week has started. Take a look at last week's spending in Flow."
    )

    /// Önceki sürümlerin hatırlatma kimlikleri; güncelleyen kullanıcılarda eski saatler kalmasın diye onlar da silinir.
    private static let legacyReminderIDs = ["daily-reminder", "daily-reminder-12", "daily-reminder-20"]

    static var reminderHours: [Int] { dailyReminders.map(\.hour) }

    private let center: any NotificationScheduling

    init(center: any NotificationScheduling = UNUserNotificationCenter.current()) {
        self.center = center
    }

    /// İzin ister. Kullanıcı daha önce reddettiyse sistem tekrar sormaz ve `false` döner.
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func isAuthorizationDenied() async -> Bool {
        await center.authorizationStatus() == .denied
    }

    /// Bekleyen hatırlatmaları kaldırır; açık olanları tekrar eden bildirimler olarak yeniden kurar.
    /// Metin kurulurken sabitlenir; uygulama dili değişince yeniden çağrılmalı.
    func updateReminders(daily: Bool, weekly: Bool, locale: Locale = .current) async throws {
        let all = Self.dailyReminders + [Self.weeklyReminder]
        center.removePendingNotificationRequests(withIdentifiers: all.map(\.identifier) + Self.legacyReminderIDs)

        var enabled: [Reminder] = []
        if daily { enabled += Self.dailyReminders }
        if weekly { enabled.append(Self.weeklyReminder) }

        for reminder in enabled {
            let content = UNMutableNotificationContent()
            content.title = LocalizedStringResource(reminder.title).localized(in: locale)
            content.body = LocalizedStringResource(reminder.body).localized(in: locale)
            // Bildirim sesleri mp3 desteklemez; aynı sesin CAF kopyası kullanılır.
            content.sound = UNNotificationSound(named: UNNotificationSoundName("NotificationSound.caf"))

            let trigger = UNCalendarNotificationTrigger(dateMatching: reminder.dateComponents, repeats: true)
            try await center.add(UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger))
        }
    }
}

extension ReminderScheduler {

    /// Ayarlarda açık olan hatırlatmaları kurar; bildirimler kapalıysa hepsini kaldırır.
    @MainActor func updateReminders(for appState: AppState, locale: Locale) async throws {
        try await updateReminders(
            daily: appState.isNotificationsOn && appState.isDailyReminderOn,
            weekly: appState.isNotificationsOn && appState.isWeeklyReminderOn,
            locale: locale
        )
    }
}
