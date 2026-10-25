import SwiftUI

/// Toast'ın çizildiği üst pencere. Dokunma yönlendirmesi iOS 26 davranışına göredir;
/// dağıtım hedefi 26.2 olduğu için eski sürümlere ait dallar kaldırıldı.
@Observable
final class PassThroughWindow: UIWindow {

    var toast: Toast? = nil
    var isPresented: Bool = false
    /// Ayrı pencere uygulamanın environment'ını miras almaz; seçili dil buradan aktarılır.
    var locale: Locale = .current

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard super.hitTest(point, with: event) != nil,
              let rootView = rootViewController?.view
        else { return nil }

        return rootView.layer.hitTest(point)?.name == nil ? rootView : nil
    }
}
