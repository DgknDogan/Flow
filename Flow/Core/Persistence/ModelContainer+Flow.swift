import Foundation
import SwiftData

extension ModelContainer {

    /// Depodaki tüm modeller; uygulama, önizleme ve test depoları aynı şemayı kullanır.
    static let flowModels: [any PersistentModel.Type] = [
        TransactionEntity.self,
        AssistantConversationEntity.self,
        AssistantMessageEntity.self
    ]

    /// Uygulamanın kalıcı deposu. Senkronizasyon açıksa entitlements'taki ilk iCloud container'ı
    /// kullanılır; iCloud capability eklenmemişse `.automatic` sessizce yerel depoya düşer.
    /// Depo adı/konumu `.modelContainer(for:)` varsayılanıyla aynıdır, mevcut veriler korunur.
    static func flow(iCloudSyncEnabled: Bool) -> ModelContainer {
        let configuration = ModelConfiguration(
            cloudKitDatabase: iCloudSyncEnabled ? .automatic : .none
        )

        do {
            return try ModelContainer(for: Schema(flowModels), configurations: configuration)
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }
}
