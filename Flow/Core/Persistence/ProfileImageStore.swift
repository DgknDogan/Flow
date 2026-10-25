import UIKit

/// Profil fotoğrafını tek bir JPEG dosyası olarak saklar. Klasör varsayılan olarak Application Support'tur;
/// testler geçici bir klasör verebilir.
nonisolated enum ProfileImageStore {

    private static let fileName = "profile-photo.jpg"

    static func load(from directory: URL = .applicationSupportDirectory) -> UIImage? {
        guard let data = try? Data(contentsOf: directory.appending(path: fileName)) else { return nil }
        return UIImage(data: data)
    }

    static func save(_ data: Data, to directory: URL = .applicationSupportDirectory) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appending(path: fileName), options: .atomic)
    }

    static func delete(from directory: URL = .applicationSupportDirectory) {
        try? FileManager.default.removeItem(at: directory.appending(path: fileName))
    }
}
