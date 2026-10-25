import Foundation

nonisolated extension LocalizedStringResource {

    /// `String(localized:)` iOS'un açılışta seçtiği dili kullanır. Uygulama içinden seçilen dil
    /// görünümler dışında (bildirim, Face ID istemi, duyurular) bu yolla uygulanır.
    func localized(in locale: Locale) -> String {
        var resource = self
        resource.locale = locale
        return String(localized: resource)
    }
}

extension Locale {

    /// Uygulamada seçili dilin locale'i. Görünümlerde bunun yerine `@Environment(\.locale)` okunmalı,
    /// böylece dil değişince görünüm yeniden çizilir.
    static var app: Locale {
        UserDefaults.appLanguage.locale
    }
}
