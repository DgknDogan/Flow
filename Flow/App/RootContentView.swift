import SwiftUI

struct RootContentView: View {
    @State private var router = AppRouter()
    @State private var appState = AppState()
    @State private var toastManager = ToastManager()
    @State private var appLock = AppLockManager()
    private let modelDownloader = GemmaModelDownloader.shared
    private let reminderScheduler = ReminderScheduler()

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch router.appFlow {
            case .onBoard:
                OnboardingView()
            case .main:
                MainView()
            case .splash:
                SplashView(isReady: !appLock.isLocked)
            }
        }
        .overlay {
            if appLock.isLocked {
                AppLockView(
                    biometryType: appLock.biometryType,
                    isAuthenticating: appLock.isAuthenticating,
                    onUnlock: unlock
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: appLock.isLocked)
        .alert("Download the Assistant?", isPresented: isCellularDownloadAlertPresented) {
            Button("Download Now") { modelDownloader.download(allowingCellular: true) }
            Button("Wait for Wi-Fi", role: .cancel) { modelDownloader.download(allowingCellular: false) }
        } message: {
            Text("The assistant needs a \(GemmaModelDownloader.expectedBytes.formatted(.byteCount(style: .file))) model. You're on mobile data, so downloading it may count toward your data plan.")
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background, appState.isBiometricLockOn {
                appLock.lock()
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await appLock.unlockAutomaticallyIfNeeded()
        }
        .task { await rescheduleReminders() }
        .environment(router)
        .environment(appState)
        .environment(toastManager)
        .preferredColorScheme(appState.appTheme.colorScheme)
        .dynamicIslandToast(
            isPresented: $toastManager.isPresented,
            toast: toastManager.currentToast,
            onDismiss: toastManager.completeDismissal
        )
        // En dışta: toast penceresi ve kilit ekranı dahil her şey seçili dili görür.
        .environment(\.locale, appState.appLanguage.locale)
    }

    /// Mobil veri onayı yalnızca ana ekranda, kilit açıkken sorulur.
    private var isCellularDownloadAlertPresented: Binding<Bool> {
        Binding(
            get: { modelDownloader.state == .awaitingCellularConsent && router.appFlow == .main && !appLock.isLocked },
            set: { _ in }
        )
    }

    private func unlock() {
        Task { await appLock.unlock() }
    }

    /// Hatırlatma saatleri ya da metinleri sürümler arasında değişebildiği için açılışta yeniden kurulur;
    /// eski sürümün bekleyen bildirimleri de böylece temizlenir.
    private func rescheduleReminders() async {
        guard appState.isNotificationsOn else { return }
        try? await reminderScheduler.updateReminders(for: appState, locale: appState.appLanguage.locale)
    }
}

#Preview {
    RootContentView()
}
