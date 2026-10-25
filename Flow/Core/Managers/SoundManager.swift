import AVFoundation

/// Kısa geri bildirim seslerini çalar.
/// Player ve audio session açılışta arka planda hazırlanır; böylece ilk çalma ana thread'i
/// (ve o sırada başlayan toast/dismiss animasyonlarını) bloklamaz.
final class SoundManager {

    static let instance = SoundManager()

    private var player: AVAudioPlayer?
    private var preparation: Task<Void, Never>?

    private init() {}

    /// Uygulama açılışında bir kez çağrılır; tekrar çağrılması zararsızdır.
    func prepare() {
        guard player == nil, preparation == nil else { return }
        preparation = Task {
            player = await Self.makePlayer()
        }
    }

    func playSound() {
        // Hazırlık henüz bitmediyse ana thread'de yüklemek yerine bu seferlik sessiz geçilir.
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }

    @concurrent
    private nonisolated static func makePlayer() async -> sending AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "NotificationSound", withExtension: "mp3") else { return nil }
        do {
            // .ambient: kullanıcının çaldığı müziği kesmez ve sessiz moda uyar.
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }
}
