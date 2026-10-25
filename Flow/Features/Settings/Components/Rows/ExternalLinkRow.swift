import SwiftUI

/// Uygulama dışına (Safari, App Store) açılan satır.
struct ExternalLinkRow: View {

    let destination: URL
    let icon: String
    let tint: Color
    let title: LocalizedStringKey

    var body: some View {
        Link(destination: destination) {
            IconRow(icon: icon, tint: tint, title: title) {
                ExternalLinkIndicator()
            }
        }
    }
}
