import SwiftUI

struct LanguageSettingsView: View {

    @Environment(AppState.self) private var appState
    @Environment(ToastManager.self) private var toastManager

    private let scheduler = ReminderScheduler()

    var body: some View {
        @Bindable var appState = appState

        List {
            Section {
                SettingsSelectionGroup(selection: $appState.appLanguage) { language in
                    if language == .system {
                        IconTile(systemName: "iphone", tint: language.tint)
                    } else {
                        LanguageBadge(code: language.badge, tint: language.tint)
                    }
                }
            } footer: {
                Text("System uses your device language when Flow supports it, and English otherwise.")
            }
        }
        .insetGroupedScreen("Language")
        .onChange(of: appState.appLanguage) { _, language in
            Task { await rescheduleReminders(in: language.locale) }
        }
    }

    /// Bildirim metni kurulurken sabitlendiği için açık hatırlatmalar yeni dilde yeniden kurulur.
    private func rescheduleReminders(in locale: Locale) async {
        guard appState.isNotificationsOn else { return }
        do {
            try await scheduler.updateReminders(for: appState, locale: locale)
        } catch {
            toastManager.show(AppToasts.reminderError)
        }
    }
}

/// `IconTile` boyutunda, sembol yerine dil kodunu gösteren rozet.
private struct LanguageBadge: View {

    let code: String
    let tint: Color

    @ScaledMetric(relativeTo: .body) private var size = 30.0

    var body: some View {
        Text(verbatim: code)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(tint.gradient, in: .rect(cornerRadius: AppRadius.icon))
            .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
    .environment(AppState())
    .environment(ToastManager())
}
