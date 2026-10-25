import SwiftUI

struct AccountSection: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        Section("Account") {
            NavigationLink(value: MainRoutes.profile) {
                HStack(spacing: 14) {
                    ProfileAvatar(image: appState.profileImage, name: appState.userName, size: 52)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.userName, placeholder: "Your Name")
                            .font(.headline)

                        Text("View profile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
