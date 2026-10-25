import UserNotifications
@testable import Flow

/// Bildirim merkezinin bellek içi sahtesi. Her test kendi örneğini tek iş parçacığında
/// kullandığı için kilit gerekmiyor.
final class FakeNotificationCenter: NotificationScheduling, @unchecked Sendable {

    var authorizationResult: Result<Bool, TestError> = .success(true)
    var status: UNAuthorizationStatus = .notDetermined
    var addError: TestError?

    private(set) var pendingRequests: [UNNotificationRequest] = []
    private(set) var removedIdentifiers: [String] = []
    private(set) var requestedOptions: UNAuthorizationOptions?

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        requestedOptions = options
        return try authorizationResult.get()
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        status
    }

    func add(_ request: UNNotificationRequest) async throws {
        if let addError { throw addError }
        pendingRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers += identifiers
        pendingRequests.removeAll { identifiers.contains($0.identifier) }
    }
}
