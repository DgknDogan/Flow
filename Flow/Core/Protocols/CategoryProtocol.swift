import SwiftUI

/// `rawValue` SwiftData'ya yazılan kalıcı anahtardır; değiştirilirse eski kayıtlar `.other`'a düşer.
/// Ekranda görünen ad `displayName` ile ayrı tutulur; böylece çevrilebilir ve yeniden adlandırılabilir.
nonisolated protocol CategoryProtocol: CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var iconName: String { get }
    var color: Color { get }
    var displayName: LocalizedStringResource { get }
}
