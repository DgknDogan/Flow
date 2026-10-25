import SwiftUI
import SwiftData

@main
struct FlowApp: App {

    private let modelContainer: ModelContainer

    init() {
        #if DEBUG
        if UITestLaunch.isEnabled {
            UITestLaunch.prepareDefaults()
            modelContainer = UITestLaunch.makeModelContainer()
            return
        }
        #endif

        // Senkronizasyon tercihi açılışta okunur; değişiklik bir sonraki açılışta uygulanır.
        modelContainer = .flow(iCloudSyncEnabled: UserDefaults.isICloudSyncOn)
    }

    /// Asistanın modeli ilk açılışta arka planda iner. UI testleri her seferinde boş bir klonda
    /// çalıştığı için 2,6 GB'ı indirmez; model önceden inmişse yine kullanılır.
    private func startModelDownload() async {
        #if DEBUG
        if AssistantBenchmark.isEnabled {
            await AssistantBenchmark.run()
            return
        }
        if UITestLaunch.isEnabled { return }
        #endif
        GemmaModelDownloader.shared.startIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .task { SoundManager.instance.prepare() }
                .task { await startModelDownload() }
        }
        .modelContainer(modelContainer)
        .backgroundTask(.urlSession(GemmaModelDownloader.wifiSessionIdentifier)) {
            await GemmaModelDownloader.shared.waitForBackgroundEvents(identifier: GemmaModelDownloader.wifiSessionIdentifier)
        }
        .backgroundTask(.urlSession(GemmaModelDownloader.cellularSessionIdentifier)) {
            await GemmaModelDownloader.shared.waitForBackgroundEvents(identifier: GemmaModelDownloader.cellularSessionIdentifier)
        }
    }
}
