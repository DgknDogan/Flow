import SwiftUI

// MARK: - Dynamic Island Toast Modifier

extension View {
    func dynamicIslandToast(isPresented: Binding<Bool>, toast: Toast?, onDismiss: (() -> Void)? = nil) -> some View {
        modifier(DynamicIslandModifier(isPresented: isPresented, toast: toast, onDismiss: onDismiss))
    }
}

/// Toast'ı uygulama penceresinin üstündeki ayrı bir pencerede gösterir ve süresi dolunca kapatır.
struct DynamicIslandModifier: ViewModifier {

    @Binding var isPresented: Bool
    let toast: Toast?
    var onDismiss: (() -> Void)?

    @Environment(\.locale) private var locale

    @State private var overlayWindow: PassThroughWindow?
    @State private var overlayController: HostingView?
    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .background(WindowExtractor(onWindow: createOverlayWindow))
            .onChange(of: isPresented, initial: true) { _, newValue in
                presentationChanged(to: newValue)
            }
            .onChange(of: overlayWindow?.isPresented) { _, newValue in
                if let newValue, let overlayWindow, let toast,
                   overlayWindow.toast?.id == toast.id, newValue != isPresented {
                    isPresented = false
                }
            }
    }

    private func presentationChanged(to presented: Bool) {
        guard let overlayWindow else { return }

        if presented {
            overlayWindow.locale = locale
            overlayWindow.toast = toast
            announce(toast)
            scheduleDismiss(after: toast?.duration ?? 3)
        } else {
            dismissTask?.cancel()
            onDismiss?()
        }

        overlayWindow.isPresented = presented
        overlayController?.isStatusBarHidden = presented
    }

    private func scheduleDismiss(after duration: TimeInterval) {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            withAnimation {
                isPresented = false
            }
        }
    }

    /// Toast ayrı bir pencerede çizildiği için VoiceOver ona odaklanmaz; içerik ayrıca duyurulur.
    private func announce(_ toast: Toast?) {
        guard let toast else { return }
        let announcement = "\(toast.title.localized(in: locale)). \(toast.message.localized(in: locale))"
        AccessibilityNotification.Announcement(announcement).post()
    }

    private func createOverlayWindow(_ mainWindow: UIWindow) {
        guard let windowScene = mainWindow.windowScene else { return }

        if let window = windowScene.windows.first(where: { $0.tag == 2000 }) as? PassThroughWindow {
            overlayWindow = window
            overlayController = window.rootViewController as? HostingView
        } else {
            let window = PassThroughWindow(windowScene: windowScene)
            window.backgroundColor = .clear
            window.isHidden = false
            window.isUserInteractionEnabled = true
            window.tag = 2000

            createRootController(in: window)
            overlayWindow = window
        }
    }

    private func createRootController(in window: PassThroughWindow) {
        let hostingController = HostingView(rootView: ToastView(window: window))
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        overlayController = hostingController
    }
}
