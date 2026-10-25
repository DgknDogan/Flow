import SwiftUI

extension Text {

    /// Değer boşsa yerelleştirilmiş yer tutucuyu, değilse değeri olduğu gibi gösterir
    /// (ör. kullanıcı adı yoksa "Your Name").
    init(_ value: String, placeholder: LocalizedStringKey) {
        self = value.isEmpty ? Text(placeholder) : Text(verbatim: value)
    }

    /// Açık/kapalı durumunu "On" / "Off" olarak gösterir.
    init(isOn: Bool) {
        self = isOn ? Text("On") : Text("Off")
    }
}
