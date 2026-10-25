#if DEBUG
import Foundation
import Synchronization
import os

/// Asistanın cihazdaki hızını ve bellek kullanımını ölçer: `-assistant-benchmark` ile açılınca gerçek
/// talimatlar, araç ve örnek işlemlerle sabit soruları sorar. Her tur konsola `BENCH` satırı olarak,
/// tüm sonuç Documents/assistant-benchmark.json'a yazılır. Arayüze dokunmaz.
enum AssistantBenchmark {

    nonisolated static let argument = "-assistant-benchmark"
    private static let rounds = 3

    nonisolated static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(argument)
    }

    private struct Scenario {
        let name: String
        let prompt: String
        /// `false` ise önceki turun oturumunda (KV önbelleği dolu) sorulur.
        let newConversation: Bool
    }

    private static let scenarios = [
        Scenario(name: "tool-total", prompt: "Bu ay ne kadar harcadım?", newConversation: true),
        Scenario(name: "follow-up-tip", prompt: "Yemek giderimi nasıl azaltabilirim?", newConversation: false),
        Scenario(name: "tool-category", prompt: "Bu ay ulaşıma ne kadar harcadım?", newConversation: true),
        Scenario(name: "long-output", prompt: "Aylık bütçe yapmak için 10 maddelik ayrıntılı bir plan yaz.", newConversation: true)
    ]

    nonisolated struct Report: Codable {
        var device: String
        var physicalMemoryMB: Int
        var osVersion: String
        var backend: String
        var isSimulator: Bool
        var thermalStateStart: String
        var thermalStateEnd = ""
        var footprintBeforeLoadMB: Double
        var footprintAfterLoadMB = 0.0
        var engineLoadSeconds = 0.0
        var turns: [Turn] = []
        var error: String?
    }

    nonisolated struct Turn: Codable {
        let round: Int
        let scenario: String
        let sessionCreateSeconds: Double
        /// Sorudan ilk görünen kelimeye kadar; araç çağrısı ve ikinci prefill dahil.
        let wallTimeToFirstTextSeconds: Double
        let wallTotalSeconds: Double
        let outputCharacters: Int
        let engineTimeToFirstTokenSeconds: Double
        let prefillTokens: Int
        let prefillTokensPerSecond: Double
        let decodeTokens: Int
        let decodeTokensPerSecond: Double
        let contextTokens: Int
        let hitOutputLimit: Bool
        /// Model aracın adını yazdı; araç uygulama tarafından çalıştırılıp cevap yeniden istendi.
        let usedToolFallback: Bool
        let peakFootprintMB: Double
        /// Turda iOS'un uygulamaya bıraktığı en az ek bellek (jetsam payı); simülatörde 0.
        let minAvailableMemoryMB: Double
        let text: String
    }

    static func run() async {
        guard FileManager.default.fileExists(atPath: GemmaModelDownloader.fileURL.path) else {
            print("BENCH error: model file missing at \(GemmaModelDownloader.fileURL.path)")
            return
        }

        var report = Report(
            device: deviceIdentifier,
            physicalMemoryMB: Int(ProcessInfo.processInfo.physicalMemory / 1_048_576),
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            backend: GemmaEngine.backendName,
            isSimulator: isSimulator,
            thermalStateStart: thermalState,
            footprintBeforeLoadMB: megabytes(footprint())
        )
        let sampler = MemorySampler()
        let samplerTask = Task.detached(priority: .high) {
            while !Task.isCancelled {
                sampler.sample()
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
        defer { samplerTask.cancel() }

        do {
            let clock = ContinuousClock()
            let loadStart = clock.now
            _ = try await GemmaEngine.shared.engine()
            report.engineLoadSeconds = seconds(clock.now - loadStart)
            report.footprintAfterLoadMB = megabytes(footprint())
            print("BENCH load \(report.engineLoadSeconds)s footprint \(report.footprintAfterLoadMB) MB backend \(report.backend)")

            let reporter = SpendingReporter(container: .preview(Transaction.samples), currency: .dollar, locale: Locale(identifier: "tr_TR"))
            SpendingSummaryTool.use(reporter)
            let instructions = AssistantInstructions.text(now: .now, calendar: .current, locale: Locale(identifier: "tr_TR"), currency: .dollar, dailyLimit: nil)

            var session: GemmaChatSession?
            for round in 1...rounds {
                for scenario in scenarios {
                    var sessionCreate = 0.0
                    if scenario.newConversation || session == nil {
                        let start = clock.now
                        session = try await GemmaChatSession.make(instructions: instructions, history: [])
                        sessionCreate = seconds(clock.now - start)
                    }
                    guard let session else { continue }

                    sampler.reset()
                    let start = clock.now
                    var firstText: Duration?
                    var text = ""
                    for try await snapshot in try await session.streamResponse(to: scenario.prompt) {
                        if firstText == nil, !snapshot.isEmpty { firstText = clock.now - start }
                        text = snapshot
                    }
                    let total = clock.now - start
                    let stats = try await session.lastTurnStats()
                    let memory = sampler.values

                    let turn = Turn(
                        round: round,
                        scenario: scenario.name,
                        sessionCreateSeconds: sessionCreate,
                        wallTimeToFirstTextSeconds: firstText.map(seconds) ?? 0,
                        wallTotalSeconds: seconds(total),
                        outputCharacters: text.count,
                        engineTimeToFirstTokenSeconds: stats.timeToFirstToken,
                        prefillTokens: stats.prefillTokens,
                        prefillTokensPerSecond: stats.prefillTokensPerSecond,
                        decodeTokens: stats.decodeTokens,
                        decodeTokensPerSecond: stats.decodeTokensPerSecond,
                        contextTokens: stats.contextTokens,
                        hitOutputLimit: stats.decodeTokens >= GemmaChatSession.maxOutputTokens,
                        usedToolFallback: stats.usedToolFallback,
                        peakFootprintMB: megabytes(memory.peakFootprint),
                        minAvailableMemoryMB: megabytes(memory.minAvailable),
                        text: text
                    )
                    report.turns.append(turn)
                    print("BENCH turn \(round) \(scenario.name) ttft \(turn.wallTimeToFirstTextSeconds)s total \(turn.wallTotalSeconds)s decode \(turn.decodeTokens) tok @ \(turn.decodeTokensPerSecond) tok/s peak \(turn.peakFootprintMB) MB fallback \(turn.usedToolFallback)")
                }
            }
        } catch {
            report.error = "\(error)"
            print("BENCH error: \(error)")
        }

        report.thermalStateEnd = thermalState
        save(report)
        print("BENCH DONE")
    }

    // MARK: - Yardımcılar

    private static func save(_ report: Report) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let url = URL.documentsDirectory.appending(path: "assistant-benchmark.json")
            try encoder.encode(report).write(to: url, options: .atomic)
            print("BENCH saved \(url.path)")
        } catch {
            print("BENCH error: couldn't save report: \(error)")
        }
    }

    private static var deviceIdentifier: String {
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulated
        }
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
    }

    private static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private static var thermalState: String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: "nominal"
        case .fair: "fair"
        case .serious: "serious"
        case .critical: "critical"
        @unknown default: "unknown"
        }
    }

    private static func seconds(_ duration: Duration) -> Double {
        let components = duration.components
        return Double(components.seconds) + Double(components.attoseconds) / 1e18
    }

    private static func megabytes(_ bytes: Int64) -> Double {
        (Double(bytes) / 1_048_576 * 10).rounded() / 10
    }

    /// jetsam'ın baktığı değer: `phys_footprint`.
    nonisolated fileprivate static func footprint() -> Int64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? Int64(info.phys_footprint) : 0
    }
}

/// Tur boyunca en yüksek bellek kullanımını ve iOS'un bıraktığı en az payı tutar.
private nonisolated final class MemorySampler: Sendable {

    struct Values {
        var peakFootprint: Int64 = 0
        var minAvailable: Int64 = .max
    }

    private let state = Mutex(Values())

    var values: Values {
        state.withLock { values in
            var copy = values
            if copy.minAvailable == .max { copy.minAvailable = 0 }
            return copy
        }
    }

    func reset() {
        state.withLock { $0 = Values() }
        sample()
    }

    func sample() {
        let footprint = AssistantBenchmark.footprint()
        let available = Int64(os_proc_available_memory())
        state.withLock {
            $0.peakFootprint = max($0.peakFootprint, footprint)
            $0.minAvailable = min($0.minAvailable, available)
        }
    }
}
#endif
