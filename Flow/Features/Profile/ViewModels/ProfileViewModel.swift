import SwiftUI
import PhotosUI
import Observation

@Observable
final class ProfileViewModel {
    
    var isNameEditAlertShowing: Bool = false
    var nameEditText: String = ""
    var showPhotoPicker: Bool = false
    var selectedPhotoItem: PhotosPickerItem?
    var isProcessing: Bool = false

    private static let photoDimension = 600.0

    func showNameEditAlert(currentName: String) {
        nameEditText = currentName
        isNameEditAlertShowing = true
    }
    
    func cancelNameEdit() {
        nameEditText = ""
        isNameEditAlertShowing = false
    }
    
    /// İsim değiştiyse kaydeder ve `true` döner.
    func saveName(to appState: AppState) -> Bool {
        let trimmedName = nameEditText.trimmingCharacters(in: .whitespacesAndNewlines)
        isNameEditAlertShowing = false
        
        guard !trimmedName.isEmpty, trimmedName != appState.userName else {
            return false
        }
        
        appState.userName = trimmedName
        return true
    }

    /// Seçilen fotoğrafı küçültüp diske yazar; başarılıysa `true` döner.
    func loadSelectedPhoto(into appState: AppState) async -> Bool {
        guard let item = selectedPhotoItem else { return false }
        isProcessing = true
        defer {
            isProcessing = false
            selectedPhotoItem = nil
        }

        do {
            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data),
                let thumbnail = await image.byPreparingThumbnail(ofSize: Self.thumbnailSize(for: image.size)),
                let jpegData = thumbnail.jpegData(compressionQuality: 0.85)
            else {
                return false
            }

            try ProfileImageStore.save(jpegData)
            withAnimation(AppAnimation.selection) {
                appState.profileImage = thumbnail
            }
            return true
        } catch {
            print("Failed to save profile photo: \(error)")
            return false
        }
    }

    func removePhoto(from appState: AppState) {
        ProfileImageStore.delete()
        withAnimation(AppAnimation.selection) {
            appState.profileImage = nil
        }
    }

    /// En-boy oranını koruyarak kısa kenarı `photoDimension`'a indirir.
    private static func thumbnailSize(for size: CGSize) -> CGSize {
        let scale = min(1, photoDimension / max(1, min(size.width, size.height)))
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
}
