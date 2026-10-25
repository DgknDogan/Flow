import UIKit

final class WindowReaderView: UIView {

    var onWindow: ((UIWindow) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window else { return }
        // Bildirim bir sonraki turda yapılır; SwiftUI görünüm güncellemesi sırasında durum değişmesin.
        Task { [onWindow] in
            onWindow?(window)
        }
    }
}
