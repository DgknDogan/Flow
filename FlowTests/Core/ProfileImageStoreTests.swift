import Testing
import UIKit
@testable import Flow

@Suite("ProfileImageStore")
@MainActor
struct ProfileImageStoreTests {

    /// Gerçek Application Support klasörüne dokunmamak için her test kendi geçici klasörünü kullanır.
    private let directory = URL.temporaryDirectory.appending(path: "ProfileImageStoreTests-\(UUID().uuidString)")

    @Test func loadReturnsNilWhenNothingIsSaved() {
        #expect(ProfileImageStore.load(from: directory) == nil)
    }

    @Test func savedPhotoCanBeLoaded() throws {
        let data = try #require(Self.samplePhotoData())

        try ProfileImageStore.save(data, to: directory)

        let image = try #require(ProfileImageStore.load(from: directory))
        #expect(image.size.width > 0)
    }

    @Test func savingCreatesMissingFolder() throws {
        let nested = directory.appending(path: "nested/folder")
        let data = try #require(Self.samplePhotoData())

        try ProfileImageStore.save(data, to: nested)

        #expect(ProfileImageStore.load(from: nested) != nil)
    }

    @Test func deleteRemovesThePhoto() throws {
        try ProfileImageStore.save(try #require(Self.samplePhotoData()), to: directory)

        ProfileImageStore.delete(from: directory)

        #expect(ProfileImageStore.load(from: directory) == nil)
    }

    private static func samplePhotoData() -> Data? {
        UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        .jpegData(compressionQuality: 0.9)
    }
}
