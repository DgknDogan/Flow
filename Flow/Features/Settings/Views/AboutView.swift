import SwiftUI

struct AboutView: View {

    // Yer tutucu: uygulama App Store Connect'te oluşturulunca `id0` gerçek Apple ID ile değiştirilmeli.
    private static let appStoreReview = URL(string: "itms-apps://itunes.apple.com/app/id0?action=write-review")!

    var body: some View {
        List {
            Section {
                VStack(spacing: 10) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white, .green.gradient)
                        .accessibilityHidden(true)

                    Text(verbatim: "Flow")
                        .font(.title3.weight(.semibold))

                    Text("Version \(appVersion) (\(appBuild))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
            }

            Section("Legal") {
                ForEach(LegalDocument.allCases, id: \.self) { document in
                    SettingsLinkRow(route: .legal(document), icon: document.icon, tint: document.tint, title: document.title)
                }
            }

            Section("Community") {
                ExternalLinkRow(destination: Self.appStoreReview, icon: "star.fill", tint: .yellow, title: "Rate on the App Store")
            }

            Section {
                Text("Made with love for better money habits.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
        }
        .insetGroupedScreen("About")
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
