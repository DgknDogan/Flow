import SwiftUI

struct SupportSection: View {

    private static let supportEmail = "info.flow@gmail.com"

    @Environment(ToastManager.self) private var toastManager
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section("Support") {
            SettingsLinkRow(route: .about, icon: "info.circle.fill", tint: .gray, title: "About")

            Button(action: contactSupport) {
                IconRow(icon: "envelope.fill", tint: .teal, title: "Contact Support") {
                    ExternalLinkIndicator()
                }
            }
            .buttonStyle(.plain)
        }
    }

    /// Mail uygulaması yoksa (ör. simülatör) adresi panoya kopyalayıp kullanıcıyı bilgilendirir.
    private func contactSupport() {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = Self.supportEmail
        components.queryItems = [URLQueryItem(name: "subject", value: "Flow Support")]
        guard let url = components.url else { return }

        openURL(url) { accepted in
            guard !accepted else { return }
            UIPasteboard.general.string = Self.supportEmail
            toastManager.show(AppToasts.supportEmailCopied)
        }
    }
}
