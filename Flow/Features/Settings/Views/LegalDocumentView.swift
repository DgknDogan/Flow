import SwiftUI

/// Kullanım koşulları, gizlilik politikası gibi metinleri uygulamanın içinde gösterir.
struct LegalDocumentView: View {

    let document: LegalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Last updated \(document.lastUpdated, format: Date.FormatStyle(date: .long, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(document.sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.heading)
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)

                        Text(section.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .localizedNavigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalDocumentView(document: .privacy)
    }
}
