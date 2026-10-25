import Testing
import UserNotifications
@testable import Flow

@Suite("ReminderScheduler")
struct ReminderSchedulerTests {

    private let center = FakeNotificationCenter()

    private var scheduler: ReminderScheduler {
        ReminderScheduler(center: center)
    }

    @Test func requestsAlertAndSoundPermission() async {
        let granted = await scheduler.requestAuthorization()

        #expect(granted)
        #expect(center.requestedOptions == [.alert, .sound])
    }

    @Test func failedPermissionRequestCountsAsDenied() async {
        center.authorizationResult = .failure(TestError())
        #expect(await scheduler.requestAuthorization() == false)
    }

    @Test(arguments: [
        (UNAuthorizationStatus.denied, true),
        (.authorized, false),
        (.notDetermined, false),
        (.provisional, false)
    ])
    func reportsDeniedOnlyWhenDenied(status: UNAuthorizationStatus, isDenied: Bool) async {
        center.status = status
        #expect(await scheduler.isAuthorizationDenied() == isDenied)
    }

    @Test func enablingDailySchedulesRepeatingMorningAndEveningReminders() async throws {
        try await scheduler.updateReminders(daily: true, weekly: false)

        #expect(center.pendingRequests.count == 2)
        #expect(ReminderScheduler.reminderHours == [9, 21])

        for (request, reminder) in zip(center.pendingRequests, ReminderScheduler.dailyReminders) {
            let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
            #expect(request.identifier == reminder.identifier)
            #expect(trigger.dateComponents.hour == reminder.hour)
            #expect(trigger.dateComponents.minute == 0)
            #expect(trigger.dateComponents.weekday == nil)
            #expect(trigger.repeats)
            #expect(!request.content.title.isEmpty)
            #expect(!request.content.body.isEmpty)
        }
    }

    @Test func enablingWeeklySchedulesMondayAfternoonReminder() async throws {
        try await scheduler.updateReminders(daily: false, weekly: true)

        let request = try #require(center.pendingRequests.first)
        let trigger = try #require(request.trigger as? UNCalendarNotificationTrigger)
        #expect(center.pendingRequests.count == 1)
        #expect(request.identifier == ReminderScheduler.weeklyReminder.identifier)
        #expect(trigger.dateComponents.weekday == 2, "Gregoryen takvimde 2 = pazartesi")
        #expect(trigger.dateComponents.hour == 13)
        #expect(trigger.dateComponents.minute == 0)
        #expect(trigger.repeats)
        #expect(!request.content.title.isEmpty)
        #expect(!request.content.body.isEmpty)
    }

    @Test func enablingTwiceDoesNotDuplicateReminders() async throws {
        try await scheduler.updateReminders(daily: true, weekly: true)
        try await scheduler.updateReminders(daily: true, weekly: true)

        #expect(center.pendingRequests.count == ReminderScheduler.dailyReminders.count + 1)
    }

    @Test func disablingRemovesTheReminders() async throws {
        try await scheduler.updateReminders(daily: true, weekly: true)
        try await scheduler.updateReminders(daily: false, weekly: false)

        #expect(center.pendingRequests.isEmpty)
        for reminder in ReminderScheduler.dailyReminders + [ReminderScheduler.weeklyReminder] {
            #expect(center.removedIdentifiers.contains(reminder.identifier))
        }
    }

    /// Eski sürümün öğlen ve akşam hatırlatmaları güncellemeden sonra kalmaz.
    @Test func updatingRemovesPreviousVersionReminders() async throws {
        try await scheduler.updateReminders(daily: true, weekly: false)

        #expect(center.removedIdentifiers.contains("daily-reminder-12"))
        #expect(center.removedIdentifiers.contains("daily-reminder-20"))
    }

    @Test func schedulingFailureIsReported() async {
        center.addError = TestError()

        await #expect(throws: TestError.self) {
            try await scheduler.updateReminders(daily: true, weekly: true)
        }
    }
}
