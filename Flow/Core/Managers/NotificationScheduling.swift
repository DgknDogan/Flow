import UserNotifications

/// `UNUserNotificationCenter`'ın uygulamada kullanılan kısmı; testlerde sahtesiyle değiştirilir.
nonisolated protocol NotificationScheduling: Sendable {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func authorizationStatus() async -> UNAuthorizationStatus
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

nonisolated extension UNUserNotificationCenter: NotificationScheduling {
    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationSettings().authorizationStatus
    }
}
