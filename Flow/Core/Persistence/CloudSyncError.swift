import Foundation
import CloudKit

/// iCloud eşitlemesinden gelen hataların sınıflandırılması.
nonisolated enum CloudSyncError {

    /// Hata iCloud depolama alanının dolu olmasından mı kaynaklanıyor. CloudKit bunu doğrudan
    /// (`quotaExceeded`), kayıt bazında kısmi hata (`partialFailure`) içinde ya da Core Data'nın
    /// sardığı alt hata (`NSUnderlyingErrorKey`) olarak bildirebilir.
    static func isQuotaExceeded(_ error: (any Error)?) -> Bool {
        guard let error else { return false }

        if let ckError = error as? CKError {
            switch ckError.code {
            case .quotaExceeded:
                return true
            case .partialFailure:
                let itemErrors = ckError.partialErrorsByItemID?.values ?? [:].values
                if itemErrors.contains(where: isQuotaExceeded) {
                    return true
                }
            default:
                break
            }
        }

        let underlying = (error as NSError).userInfo[NSUnderlyingErrorKey] as? any Error
        return isQuotaExceeded(underlying)
    }
}
