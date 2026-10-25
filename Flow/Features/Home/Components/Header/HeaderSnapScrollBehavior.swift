import SwiftUI

/// Kaydırma bittiğinde başlığı tam açık (0) ya da tam kapalı (100) konuma oturtur.
struct HeaderSnapScrollBehavior: ScrollTargetBehavior {

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let y = target.rect.minY

        if y > 0 && y < 100 {
            target.rect.origin.y = y < 50 ? 0 : 100
        }

        if y >= 100 && y < 130 {
            target.rect.origin.y = 100
        }
    }
}
