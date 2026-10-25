import SwiftUI
import SwiftData
import CoreData
import Combine

struct MainView: View {

    @Environment(AppRouter.self) private var router
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = MainViewModel()

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab(Tabs.home.title, systemImage: Tabs.home.systemImage, value: Tabs.home) {
                NavigationStack(path: $router.homePath) {
                    HomeView()
                        .mainViewRoute()
                }
            }

            Tab(Tabs.details.title, systemImage: Tabs.details.systemImage, value: Tabs.details) {
                NavigationStack(path: $router.detailsPath) {
                    DetailsView()
                        .mainViewRoute()
                }
            }

            Tab(Tabs.settings.title, systemImage: Tabs.settings.systemImage, value: Tabs.settings) {
                NavigationStack(path: $router.settingsPath) {
                    SettingsView()
                        .mainViewRoute()
                }
            }

            Tab(Tabs.assistant.title, systemImage: Tabs.assistant.systemImage, value: Tabs.assistant, role: .search) {
                NavigationStack(path: $router.assistantPath) {
                    AssistantView()
                        .mainViewRoute()
                }
            }
        }
        .addTransactionSheet(isPresented: $router.isAddTransactionPresented, onSave: viewModel.appendTransaction)
        .environment(viewModel)
        .onReceive(
            NotificationCenter.default
                .publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
                .receive(on: RunLoop.main),
            perform: handleCloudKitEvent
        )
    }

    /// iCloud olayları: başka cihazdan gelen işlemler içe aktarılınca liste tazelenir; gönderim
    /// bitince iCloud alanının dolu olup olmadığı kaydedilir (iCloud Sync ekranında uyarı için).
    private func handleCloudKitEvent(_ notification: Notification) {
        guard
            let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event,
            event.endDate != nil
        else { return }

        switch event.type {
        case .import where event.succeeded:
            viewModel.loadTransactions(in: modelContext)
        case .export:
            appState.isICloudStorageFull = !event.succeeded && CloudSyncError.isQuotaExceeded(event.error)
        default:
            break
        }
    }
}

#if DEBUG
#Preview {
    MainView()
        .previewEnvironment()
}
#endif
