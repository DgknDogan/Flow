import SwiftUI

/// Uygulamanın arayüz dili. `system` cihaz dilini izler. Seçim kökte `\.locale` olarak uygulanır ve
/// hemen geçerli olur; iOS'un çizdiği parçalar (sistem alert'leri, PhotosPicker) için ayrıca
/// `AppleLanguages` yazılır, onlar bir sonraki açılışta değişir.
nonisolated enum AppLanguage: String, CaseIterable, TitledOption {
    case system
    case english = "en"
    case turkish = "tr"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case german = "de"

    /// Dil adları her dilde kendi yazılışıyla gösterilir; katalogda çevrilmeyecek olarak işaretli.
    var title: LocalizedStringResource {
        switch self {
        case .system: "System"
        case .english: "English"
        case .turkish: "Türkçe"
        case .french: "Français"
        case .spanish: "Español"
        case .italian: "Italiano"
        case .german: "Deutsch"
        }
    }

    /// `AppleLanguages`'a yazılan kod; `system` için `nil`.
    var languageCode: String? {
        self == .system ? nil : rawValue
    }

    /// Seçili dil ile cihazın bölge ayarları (para, tarih sırası, hafta başı) birleşimi.
    var locale: Locale {
        var components = Locale.Components(locale: .autoupdatingCurrent)
        components.languageComponents = Locale.Language.Components(identifier: languageCode ?? Self.deviceLanguageCode)
        return Locale(components: components)
    }

    /// Cihaz dillerinden Flow'un desteklediği ilki; hiçbiri desteklenmiyorsa İngilizce.
    private static var deviceLanguageCode: String {
        Bundle.preferredLocalizations(from: Bundle.main.localizations, forPreferences: Locale.preferredLanguages).first ?? "en"
    }

    /// Satırdaki rozette görünen kısa kod.
    var badge: String {
        languageCode?.uppercased() ?? ""
    }

    var tint: Color {
        switch self {
        case .system: .gray
        case .english: .blue
        case .turkish: .red
        case .french: .indigo
        case .spanish: .orange
        case .italian: .green
        case .german: .teal
        }
    }
}
