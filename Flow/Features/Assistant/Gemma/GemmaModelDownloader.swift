import Foundation
import Network
import Observation

/// Asistanın kullandığı Gemma 4 E2B dosyasını indirir.
/// İndirme arka plan oturumunda sürer; uygulama askıya alınsa da devam eder. Wi-Fi'de kendiliğinden
/// başlar; mobil veride ya da Düşük Veri Modu'nda önce kullanıcıya sorulur.
@Observable
final class GemmaModelDownloader {

    enum State: Equatable {
        case notDownloaded
        /// Bağlantı mobil veri; kullanıcı onay verene kadar indirme başlamaz.
        case awaitingCellularConsent
        case waitingForWiFi
        case downloading(progress: Double)
        case insufficientStorage
        case failed
        case ready
    }

    static let shared = GemmaModelDownloader()

    nonisolated static let remoteURL = URL(string: "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm?download=true")!
    nonisolated static let expectedBytes: Int64 = 2_583_000_000
    /// Dosyanın yanında indirme ve motorun önbellekleri için bırakılan pay.
    private static let requiredFreeBytes: Int64 = expectedBytes + 500_000_000

    nonisolated static var fileURL: URL {
        URL.applicationSupportDirectory.appending(path: "Models/gemma-4-E2B-it.litertlm")
    }

    /// İki ayrı arka plan oturumu: biri yalnızca Wi-Fi, diğeri mobil veriye de izin verir. Kullanıcı
    /// sonradan mobil veriye izin verirse yarım kalan indirme diğer oturumda kaldığı yerden sürer.
    static let wifiSessionIdentifier = "com.dogukan.Flow.gemma-download.wifi"
    static let cellularSessionIdentifier = "com.dogukan.Flow.gemma-download.cellular"

    private(set) var state: State

    @ObservationIgnored private let delegate = DownloadDelegate()
    @ObservationIgnored private lazy var wifiSession = makeSession(identifier: Self.wifiSessionIdentifier, allowsCellular: false)
    @ObservationIgnored private lazy var cellularSession = makeSession(identifier: Self.cellularSessionIdentifier, allowsCellular: true)
    @ObservationIgnored private let pathMonitor = NWPathMonitor()
    @ObservationIgnored private var currentPath: NWPath?
    @ObservationIgnored private var activeTask: URLSessionDownloadTask?
    @ObservationIgnored private var resumeData: Data?
    /// Kullanıcı bu açılışta "Wi-Fi'yi Bekle" dediyse mobil veriye geçişte tekrar sorulmaz.
    @ObservationIgnored private var didDeclineCellular = false
    @ObservationIgnored private var isStarted = false
    @ObservationIgnored private var backgroundEventWaiters: [String: CheckedContinuation<Void, Never>] = [:]

    private init() {
        state = FileManager.default.fileExists(atPath: Self.fileURL.path) ? .ready : .notDownloaded

        delegate.onProgress = { [weak self] progress in
            Task { @MainActor in self?.updateProgress(progress) }
        }
        delegate.onFinish = { [weak self] result in
            Task { @MainActor in self?.finish(result) }
        }
        delegate.onBackgroundEventsFinished = { [weak self] identifier in
            Task { @MainActor in self?.backgroundEventWaiters.removeValue(forKey: identifier)?.resume() }
        }
    }

    // MARK: - Başlatma

    /// Açılışta çağrılır: dosya yoksa ve indirme sürmüyorsa ağ durumuna göre indirmeyi başlatır
    /// ya da mobil veri onayı ister.
    func startIfNeeded() {
        guard state != .ready, !isStarted else { return }
        isStarted = true

        Task {
            // Önceki açılıştan kalan indirme sürüyorsa yenisi başlatılmaz.
            if let task = await existingTask() {
                activeTask = task
                let isWaiting = task.countOfBytesReceived == 0 && task.taskDescription == Self.wifiSessionIdentifier
                state = isWaiting ? .waitingForWiFi : .downloading(progress: progress(of: task))
            }

            pathMonitor.pathUpdateHandler = { [weak self] path in
                Task { @MainActor in self?.networkChanged(path) }
            }
            pathMonitor.start(queue: DispatchQueue(label: "com.dogukan.Flow.gemma-download.path"))
        }
    }

    /// Başarısız ya da yer yetmediği için duran indirmeyi yeniden dener; mobil veride yine sorulur.
    func retry() {
        if let currentPath, currentPath.status == .satisfied, currentPath.isExpensive || currentPath.isConstrained {
            state = .awaitingCellularConsent
        } else {
            startDownload(allowingCellular: false)
        }
    }

    /// Kullanıcının indirme seçimi: mobil veriyle hemen ya da Wi-Fi'yi bekleyerek.
    func download(allowingCellular: Bool) {
        didDeclineCellular = !allowingCellular
        startDownload(allowingCellular: allowingCellular)
    }

    private func networkChanged(_ path: NWPath) {
        let previous = currentPath
        currentPath = path
        guard state != .ready, state != .insufficientStorage else { return }

        let needsConsent = path.status == .satisfied && (path.isExpensive || path.isConstrained)
        if activeTask == nil, previous == nil, state != .failed {
            // İlk ağ bilgisi geldi: Wi-Fi'de hemen başlanır, mobil veride sorulur.
            if needsConsent {
                state = .awaitingCellularConsent
            } else {
                startDownload(allowingCellular: false)
            }
        } else if needsConsent, !didDeclineCellular, state == .waitingForWiFi || isDownloadingOverWiFiOnly {
            // Wi-Fi'den çıkıldı ve yalnızca Wi-Fi'de süren indirme durdu: devam için sorulur.
            state = .awaitingCellularConsent
        } else if !needsConsent, path.status == .satisfied, state == .awaitingCellularConsent, activeTask == nil {
            // Soru cevaplanmadan Wi-Fi'ye geçildi: sormaya gerek kalmadı.
            startDownload(allowingCellular: false)
        }
    }

    private var isDownloadingOverWiFiOnly: Bool {
        guard case .downloading = state, let activeTask else { return false }
        return activeTask.taskDescription == Self.wifiSessionIdentifier
    }

    private func startDownload(allowingCellular: Bool) {
        guard hasEnoughStorage() else {
            state = .insufficientStorage
            return
        }

        let session = allowingCellular ? cellularSession : wifiSession
        if let activeTask, activeTask.taskDescription == (allowingCellular ? Self.cellularSessionIdentifier : Self.wifiSessionIdentifier) {
            // Aynı oturumda zaten bir indirme var; bekliyor ya da sürüyor.
            updateStateForWaiting(allowingCellular: allowingCellular)
            return
        }

        Task {
            // Diğer oturumdaki indirme durdurulur, gelen veri yeni oturumda kaldığı yerden sürer.
            if let activeTask {
                delegate.ignore(activeTask, in: activeTask.taskDescription ?? "")
                resumeData = await activeTask.cancelByProducingResumeData() ?? resumeData
                self.activeTask = nil
            }

            let task = resumeData.map { session.downloadTask(withResumeData: $0) } ?? session.downloadTask(with: Self.remoteURL)
            resumeData = nil
            task.taskDescription = allowingCellular ? Self.cellularSessionIdentifier : Self.wifiSessionIdentifier
            task.countOfBytesClientExpectsToReceive = Self.expectedBytes
            task.resume()
            activeTask = task
            updateStateForWaiting(allowingCellular: allowingCellular)
        }
    }

    private func updateStateForWaiting(allowingCellular: Bool) {
        if case .downloading = state { return }
        let onWiFi = currentPath.map { $0.status == .satisfied && !$0.isExpensive && !$0.isConstrained } ?? false
        state = allowingCellular || onWiFi ? .downloading(progress: 0) : .waitingForWiFi
    }

    // MARK: - Oturum olayları

    private func updateProgress(_ progress: Double) {
        guard state != .ready else { return }
        // Arayüz her yüzde birlik değişimde güncellenir.
        if case .downloading(let current) = state, abs(current - progress) < 0.01, progress < 1 { return }
        state = .downloading(progress: progress)
    }

    private func finish(_ result: DownloadDelegate.Result) {
        activeTask = nil
        switch result {
        case .success:
            state = .ready
            pathMonitor.cancel()
        case .failure(let resumeData):
            self.resumeData = resumeData ?? self.resumeData
            state = .failed
        }
    }

    /// Uygulama arka planda indirme olayları için açıldığında, olaylar teslim edilene kadar bekler.
    func waitForBackgroundEvents(identifier: String) async {
        // Oturum ilk kullanımda kurulur; sistem olayları ancak o zaman teslim eder.
        _ = identifier == Self.wifiSessionIdentifier ? wifiSession : cellularSession
        await withCheckedContinuation { continuation in
            backgroundEventWaiters[identifier] = continuation
        }
    }

    // MARK: - Yardımcılar

    private func makeSession(identifier: String, allowsCellular: Bool) -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.allowsExpensiveNetworkAccess = allowsCellular
        configuration.allowsConstrainedNetworkAccess = allowsCellular
        configuration.allowsCellularAccess = allowsCellular
        configuration.sessionSendsLaunchEvents = true
        configuration.isDiscretionary = false
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }

    private func existingTask() async -> URLSessionDownloadTask? {
        for session in [cellularSession, wifiSession] {
            let tasks = await session.allTasks.compactMap { $0 as? URLSessionDownloadTask }
            if let task = tasks.first(where: { $0.state == .running || $0.state == .suspended }) {
                task.taskDescription = session.configuration.identifier
                return task
            }
        }
        return nil
    }

    private func progress(of task: URLSessionDownloadTask) -> Double {
        let total = task.countOfBytesExpectedToReceive > 0 ? task.countOfBytesExpectedToReceive : Self.expectedBytes
        return min(Double(task.countOfBytesReceived) / Double(total), 1)
    }

    private func hasEnoughStorage() -> Bool {
        let values = try? URL.applicationSupportDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        guard let available = values?.volumeAvailableCapacityForImportantUsage else { return true }
        return available >= Self.requiredFreeBytes
    }
}

// MARK: - Delegate

/// Arka plan oturumunun olaylarını alır. İndirilen geçici dosya bu çağrı bitmeden silindiği için
/// yerine taşıma burada, eşzamanlı yapılır; sonuç ana aktöre iletilir.
private nonisolated final class DownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {

    enum Result {
        case success
        case failure(resumeData: Data?)
    }

    var onProgress: (@Sendable (Double) -> Void)?
    var onFinish: (@Sendable (Result) -> Void)?
    var onBackgroundEventsFinished: (@Sendable (String) -> Void)?
    private let lock = NSLock()
    /// Bilerek iptal edilen (diğer oturuma aktarılan) görevler; hataları bildirilmez.
    private var ignoredTasks: Set<String> = []
    /// Dosyası yerine taşınmış görevler.
    private var finishedTasks: Set<String> = []

    func ignore(_ task: URLSessionTask, in sessionIdentifier: String) {
        lock.withLock { _ = ignoredTasks.insert(Self.key(task, sessionIdentifier)) }
    }

    private static func key(_ task: URLSessionTask, _ sessionIdentifier: String?) -> String {
        "\(sessionIdentifier ?? "")#\(task.taskIdentifier)"
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let total = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : GemmaModelDownloader.expectedBytes
        onProgress?(min(Double(totalBytesWritten) / Double(total), 1))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            print("Gemma download failed with response: \(String(describing: downloadTask.response))")
            return
        }

        do {
            var destination = GemmaModelDownloader.fileURL
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: location, to: destination)

            // 2,6 GB'lık dosya iCloud yedeğine girmez; gerekirse yeniden indirilir.
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try destination.setResourceValues(values)
            lock.withLock { _ = finishedTasks.insert(Self.key(downloadTask, session.configuration.identifier)) }
        } catch {
            print("Failed to move Gemma model: \(error)")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let key = Self.key(task, session.configuration.identifier)
        let (isIgnored, didFinish) = lock.withLock {
            (ignoredTasks.remove(key) != nil, finishedTasks.remove(key) != nil)
        }
        guard !isIgnored else { return }

        if didFinish, error == nil {
            onFinish?(.success)
        } else {
            if let error { print("Gemma download failed: \(error)") }
            let resumeData = (error as? NSError)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            onFinish?(.failure(resumeData: resumeData))
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        guard let identifier = session.configuration.identifier else { return }
        onBackgroundEventsFinished?(identifier)
    }
}
