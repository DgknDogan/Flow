import SwiftUI

/// İkon kutusu + başlık (+ alt başlık) + sağda isteğe bağlı içerik.
/// Ayarlar, profil ve kategori satırlarının ortak düzeni; VoiceOver'da tek öğe olarak okunur.
struct IconRow<Trailing: View>: View {

    private let icon: String
    private let tint: Color
    private let title: Text
    private let subtitle: Text?
    private let trailing: Trailing

    init(
        icon: String,
        tint: Color,
        title: Text,
        subtitle: Text? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.icon = icon
        self.tint = tint
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            IconTile(systemName: icon, tint: tint)

            VStack(alignment: .leading, spacing: 2) {
                title
                    .foregroundStyle(Color.primary)

                if let subtitle {
                    subtitle
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            trailing
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Convenience

extension IconRow {
    init(
        icon: String,
        tint: Color,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(icon: icon, tint: tint, title: Text(title), subtitle: subtitle.map { Text($0) }, trailing: trailing)
    }
}

extension IconRow where Trailing == EmptyView {
    init(icon: String, tint: Color, title: Text, subtitle: Text? = nil) {
        self.init(icon: icon, tint: tint, title: title, subtitle: subtitle) { EmptyView() }
    }

    init(icon: String, tint: Color, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) {
        self.init(icon: icon, tint: tint, title: Text(title), subtitle: subtitle.map { Text($0) })
    }
}

#Preview {
    List {
        IconRow(icon: "bell.fill", tint: .orange, title: "Notifications") {
            Text(isOn: true)
                .foregroundStyle(.secondary)
        }
        IconRow(icon: "icloud.fill", tint: .cyan, title: "iCloud Sync", subtitle: "Keep transactions on all your devices")
    }
}
