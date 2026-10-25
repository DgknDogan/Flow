import SwiftUI

/// Arka plana yerleştirildiği görünümün `UIWindow`'unu, pencereye bağlandığı anda bildirir.
struct WindowExtractor: UIViewRepresentable {

    let onWindow: (UIWindow) -> Void

    func makeUIView(context: Context) -> WindowReaderView {
        let view = WindowReaderView()
        view.onWindow = onWindow
        return view
    }

    func updateUIView(_ uiView: WindowReaderView, context: Context) { }
}
