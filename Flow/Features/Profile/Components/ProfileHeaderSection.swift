import SwiftUI

struct ProfileHeaderSection: View {

    let viewModel: ProfileViewModel

    @Environment(AppState.self) private var appState

    var body: some View {
        Section {
            VStack(spacing: 12) {
                Menu {
                    Button("Choose Photo", systemImage: "photo.on.rectangle", action: choosePhoto)

                    if appState.profileImage != nil {
                        Button("Remove Photo", systemImage: "trash", role: .destructive, action: removePhoto)
                    }
                } label: {
                    VStack(spacing: 10) {
                        ProfileAvatar(image: appState.profileImage, name: appState.userName, size: 96)
                            .overlay {
                                if viewModel.isProcessing {
                                    Circle()
                                        .fill(.black.opacity(0.35))
                                    ProgressView()
                                        .tint(.white)
                                }
                            }

                        Text(appState.profileImage == nil ? "Add Photo" : "Edit Photo")
                            .font(.footnote.weight(.semibold))
                    }
                }
                .disabled(viewModel.isProcessing)
                .accessibilityLabel("Profile photo")

                VStack(spacing: 4) {
                    Text(appState.userName, placeholder: "Your Name")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(appState.userName.isEmpty ? .secondary : .primary)

                    Text("Member since \(appState.memberSince, format: .dateTime.month(.wide).year())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    private func choosePhoto() {
        viewModel.showPhotoPicker = true
    }

    private func removePhoto() {
        viewModel.removePhoto(from: appState)
    }
}
