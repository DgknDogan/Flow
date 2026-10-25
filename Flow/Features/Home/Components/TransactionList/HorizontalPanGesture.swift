import SwiftUI

/// Sadece yatay hareketle başlayan pan gesture'ı. SwiftUI `DragGesture` her yöne tepki verip
/// ScrollView'un dikey kaydırmasını engellediği için yön kontrolü UIKit tarafında yapılır.
struct HorizontalPanGesture: UIGestureRecognizerRepresentable {

    var onChanged: (Double) -> Void
    var onEnded: (Double) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let xTranslation = recognizer.translation(in: recognizer.view).x
        switch recognizer.state {
        case .changed:
            onChanged(xTranslation)
        case .ended, .cancelled, .failed:
            onEnded(xTranslation)
        default:
            break
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }
    }
}
