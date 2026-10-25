import SwiftUI

extension View {

    /// Seçili durumu VoiceOver'a `.isSelected` olarak bildirir.
    func accessibilitySelected(_ isSelected: Bool) -> some View {
        accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
