import Foundation
@preconcurrency import LiteRTLM

/// İndirilen Gemma 4 E2B dosyasını LiteRT-LM ile belleğe alır. Yükleme saniyeler sürdüğü için motor
/// bir kez kurulur ve uygulama açık kaldıkça bütün sohbetlerde paylaşılır.
actor GemmaEngine {

    static let shared = GemmaEngine()

    /// KV önbelleğinin boyu: talimatlar, geçmiş, araç çıktısı ve cevap birlikte buna sığmalı.
    static let contextTokenLimit = 4096

    private var loadTask: Task<Engine, any Error>?

    func engine() async throws -> Engine {
        if let loadTask {
            return try await loadTask.value
        }

        let task = Task<Engine, any Error>(priority: .userInitiated) {
            #if DEBUG
            if AssistantBenchmark.isEnabled {
                // Ölçüm için motor her turun TTFT ve tok/s değerlerini tutar.
                ExperimentalFlags.optIntoExperimentalAPIs()
                ExperimentalFlags.enableBenchmark = true
            }
            #endif
            let config = try EngineConfig(
                modelPath: GemmaModelDownloader.fileURL.path,
                backend: Self.backend,
                maxNumTokens: Self.contextTokenLimit,
                cacheDir: try Self.cacheDirectory().path
            )
            let engine = Engine(engineConfig: config)
            try await engine.initialize()
            return engine
        }
        loadTask = task

        do {
            return try await task.value
        } catch {
            // Bozuk ya da yarım dosyada sonraki deneme baştan yükler.
            loadTask = nil
            throw error
        }
    }

    /// Ölçüm raporları için: "gpu" ya da "cpu".
    static var backendName: String {
        backend.rawValue
    }

    /// Gerçek cihazda her zaman Metal GPU. iPhone 13 Pro'da ölçüldü: GPU ~28 tok/s ve en fazla
    /// ~960 MB; CPU ise ~17 tok/s ve ~1,95 GB (XNNPACK ağırlıkları ayrıca belleğe açıyor). Yani GPU
    /// hem hızlı hem de az RAM'li cihazlar için daha güvenli. Simülatörde GPU olmadığı için CPU.
    static var backend: Backend {
        #if DEBUG
        // Ölçümde GPU ile CPU'yu karşılaştırmak için: `-assistantBackend cpu`.
        switch UserDefaults.standard.string(forKey: "assistantBackend") {
        case "cpu": return .cpu()
        case "gpu": return .gpu
        default: break
        }
        #endif
        #if targetEnvironment(simulator)
        return .cpu()
        #else
        return .gpu
        #endif
    }

    /// Derlenmiş GPU programları burada tutulur; ikinci açılıştan itibaren motor çok daha hızlı yüklenir.
    private static func cacheDirectory() throws -> URL {
        let directory = URL.cachesDirectory.appending(path: "Gemma")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
