import SwiftUI

extension View {

    /// Ayarlar tarzı alt ekranların ortak görünümü: inset grouped liste ve satır içi başlık.
    func insetGroupedScreen(_ title: LocalizedStringResource) -> some View {
        self
            .listStyle(.insetGrouped)
            .localizedNavigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }

    /// Başlığı seçili uygulama dilinde çözülmüş metin olarak verir. Anahtar olarak verilen başlık
    /// navigasyon çubuğunda `\.locale` değişince her zaman yenilenmiyor.
    func localizedNavigationTitle(_ title: LocalizedStringResource) -> some View {
        modifier(LocalizedNavigationTitle(title: title))
    }
}

private struct LocalizedNavigationTitle: ViewModifier {

    let title: LocalizedStringResource

    @Environment(\.locale) private var locale

    func body(content: Content) -> some View {
        content.navigationTitle(title.localized(in: locale))
    }
}
