import SwiftUI

/// Uygulama dışına (Safari, Mail, App Store) açılan satırların sağındaki ok.
struct ExternalLinkIndicator: View {

    var body: some View {
        Image(systemName: "arrow.up.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
}
