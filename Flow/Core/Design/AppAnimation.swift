import SwiftUI

/// Uygulamada tekrar eden animasyonlar; süreler tek yerden ayarlanır.
enum AppAnimation {
    /// Form adımları ve sheet yüksekliği gibi büyük içerik geçişleri.
    static let stepTransition: Animation = .smooth(duration: 0.4, extraBounce: 0)
    /// Kategori, gün, ay gibi seçimlerin değişimi.
    static let selection: Animation = .smooth
    /// Ayar listelerinde seçim işaretinin satırlar arasında kayması.
    static let checkmark: Animation = .snappy(duration: 0.35)
    /// Arama alanının açılıp kapanması ve üstteki butonların yer değiştirmesi.
    static let search: Animation = .bouncy(duration: 0.4)
    /// Liste bölümlerinin görünüp kaybolması.
    static let sectionToggle: Animation = .easeInOut(duration: 0.3)
    /// Asistanda yeni sohbete ya da geçmişten bir sohbete geçiş.
    static let conversationSwap: Animation = .smooth(duration: 0.45)
    /// Gönderilen mesajın giriş alanından ya da öneri kartından balonuna uçması.
    static let messageHero: Animation = .spring(duration: 0.5, bounce: 0.18)
    /// Asistan karşılama ekranındaki öğelerin sırayla belirmesi; her öğe bir öncekinden bu kadar sonra başlar.
    static let welcomeStagger = 0.06
}
