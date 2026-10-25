import SwiftUI

struct NotificationSettingsView: View {

    @Environment(AppState.self) private var appState
    @Environment(ToastManager.self) private var toastManager
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale

    @State private var isPermissionDenied = false

    private let scheduler = ReminderScheduler()

    var body: some View {
        @Bindable var appState = appState

        List {
            Section {
                SettingsToggleRow(
                    icon: "bell.fill",
                    tint: .orange,
                    title: "Allow Notifications",
                    isOn: $appState.isNotificationsOn
                )
            } footer: {
                Text("Turn on to get a reminder to log your expenses.")
            }

            if isPermissionDenied {
                Section {
                    Button("Open Settings", systemImage: "gear", action: openSystemSettings)
                } footer: {
                    Text("Notifications are turned off for Flow. You can allow them in the Settings app.")
                }
            }

            if appState.isNotificationsOn {
                Section("Reminders") {
                    SettingsToggleRow(
                        icon: "sun.max.fill",
                        tint: .yellow,
                        title: "Daily Reminder",
                        subtitle: "Log your expenses every day at \(reminderTimesText)",
                        isOn: $appState.isDailyReminderOn
                    )
                    SettingsToggleRow(
                        icon: "calendar.badge.clock",
                        tint: .purple,
                        title: "Weekly Reminder",
                        subtitle: "Every \(weeklyReminderDay) at \(formattedTime(ReminderScheduler.weeklyReminder.hour))",
                        isOn: $appState.isWeeklyReminderOn
                    )
                }
            }
        }
        .animation(AppAnimation.sectionToggle, value: appState.isNotificationsOn)
        .animation(AppAnimation.sectionToggle, value: isPermissionDenied)
        .insetGroupedScreen("Notifications")
        .task {
            isPermissionDenied = await scheduler.isAuthorizationDenied()
        }
        .onChange(of: appState.isNotificationsOn) { _, isOn in
            Task { await notificationsToggled(isOn: isOn) }
        }
        .onChange(of: appState.isDailyReminderOn) {
            Task { await syncReminders() }
        }
        .onChange(of: appState.isWeeklyReminderOn) {
            Task { await syncReminders() }
        }
    }

    /// "9:00 AM and 9:00 PM" gibi; saatler ve bağlaç seçili dile göre biçimlenir.
    private var reminderTimesText: String {
        ReminderScheduler.reminderHours
            .map(formattedTime)
            .formatted(.list(type: .and).locale(locale))
    }

    /// Haftalık hatırlatmanın günü, seçili dilde ("Monday", "Pazartesi").
    private var weeklyReminderDay: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        guard let weekday = ReminderScheduler.weeklyReminder.weekday else { return "" }
        return calendar.weekdaySymbols[weekday - 1]
    }

    private func formattedTime(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
        return date.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale))
    }

    /// Açılırken izin istenir; reddedilirse anahtar geri kapatılır ve Ayarlar'a yönlendirme gösterilir.
    private func notificationsToggled(isOn: Bool) async {
        if isOn {
            let granted = await scheduler.requestAuthorization()
            isPermissionDenied = !granted
            guard granted else {
                appState.isNotificationsOn = false
                return
            }
        }
        await syncReminders()
    }

    private func syncReminders() async {
        do {
            try await scheduler.updateReminders(for: appState, locale: locale)
        } catch {
            toastManager.show(AppToasts.reminderError)
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(AppState())
            .environment(ToastManager())
    }
}
