import Foundation

/// Ekranda başlığıyla seçilen seçenekler (segmented picker, ayar seçim listeleri).
nonisolated protocol TitledOption: Hashable {
    var title: LocalizedStringResource { get }
}
