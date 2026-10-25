import SwiftUI

/// Bir ayar ekranına giden satır. `NavigationLink(value:)` sekmenin path'ine ekler ve oku kendisi çizer.
struct SettingsLinkRow: View {

    let route: MainRoutes
    let icon: String
    let tint: Color
    let title: LocalizedStringResource
    var detail: Text? = nil

    var body: some View {
        NavigationLink(value: route) {
            IconRow(icon: icon, tint: tint, title: Text(title)) {
                if let detail {
                    detail
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityIdentifier("settingsRow.\(route)")
    }
}
