import SwiftUI

/// Detent yüksekliğini animasyonlu değiştirebilmek için yüksekliği animatable olarak taşır.
@Animatable
struct SheetHeightModifier: ViewModifier {

    var height: Double

    func body(content: Content) -> some View {
        content
            .presentationDetents(height == .zero ? [.medium] : [.height(height)])
    }
}
