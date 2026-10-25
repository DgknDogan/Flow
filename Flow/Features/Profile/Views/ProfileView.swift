import SwiftUI
import PhotosUI

struct ProfileView: View {

    @Environment(AppState.self) private var appState
    @Environment(MainViewModel.self) private var mainVM
    @Environment(ToastManager.self) private var toastManager

    @State private var viewModel = ProfileViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        List {
            ProfileHeaderSection(viewModel: viewModel)
            ProfilePersonalSection(onEditName: showNameEditor)
            // İstatistikler ayrı bir görünümde hesaplanır; böylece yalnızca işlemler değişince yeniden hesaplanır.
            ProfileStatsSections(transactions: mainVM.transactions)
        }
        .insetGroupedScreen("Profile")
        .listSectionSpacing(.compact)
        .photosPicker(
            isPresented: $viewModel.showPhotoPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        .task(id: viewModel.selectedPhotoItem) {
            await saveSelectedPhoto()
        }
        .alert("Edit Name", isPresented: $viewModel.isNameEditAlertShowing) {
            TextField("Enter your name", text: $viewModel.nameEditText)
                .textInputAutocapitalization(.words)

            Button("Cancel", role: .cancel, action: cancelNameEdit)
            Button("Save", action: saveName)
        } message: {
            Text("Enter a new name or edit the old one.")
        }
    }

    private func showNameEditor() {
        viewModel.showNameEditAlert(currentName: appState.userName)
    }

    private func cancelNameEdit() {
        viewModel.cancelNameEdit()
    }

    private func saveName() {
        if viewModel.saveName(to: appState) {
            toastManager.show(AppToasts.profileUpdated)
        }
    }

    private func saveSelectedPhoto() async {
        guard viewModel.selectedPhotoItem != nil else { return }
        let didSave = await viewModel.loadSelectedPhoto(into: appState)
        toastManager.show(didSave ? AppToasts.profileUpdated : AppToasts.profilePhotoError)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProfileView()
    }
    .previewEnvironment()
}
#endif
