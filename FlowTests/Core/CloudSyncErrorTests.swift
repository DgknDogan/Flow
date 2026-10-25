import Testing
import Foundation
import CloudKit
@testable import Flow

@Suite("CloudSyncError")
struct CloudSyncErrorTests {

    @Test func quotaExceededIsDetected() {
        #expect(CloudSyncError.isQuotaExceeded(CKError(.quotaExceeded)))
    }

    /// CloudKit toplu gönderimde hatayı kayıt bazında `partialFailure` içinde bildirir.
    @Test func quotaInsidePartialFailureIsDetected() {
        let error = Self.partialFailure([CKError(.quotaExceeded)])

        #expect(CloudSyncError.isQuotaExceeded(error))
    }

    @Test func partialFailureWithoutQuotaIsIgnored() {
        let error = Self.partialFailure([CKError(.serverRecordChanged), CKError(.zoneBusy)])

        #expect(!CloudSyncError.isQuotaExceeded(error))
    }

    /// Core Data CloudKit hatasını kendi hatasının içine sarabilir.
    @Test func wrappedQuotaErrorIsDetected() {
        let wrapped = NSError(domain: NSCocoaErrorDomain, code: 134_400, userInfo: [NSUnderlyingErrorKey: CKError(.quotaExceeded)])

        #expect(CloudSyncError.isQuotaExceeded(wrapped))
    }

    @Test func otherErrorsAreIgnored() {
        #expect(!CloudSyncError.isQuotaExceeded(nil))
        #expect(!CloudSyncError.isQuotaExceeded(CKError(.networkUnavailable)))
        #expect(!CloudSyncError.isQuotaExceeded(CKError(.notAuthenticated)))
        #expect(!CloudSyncError.isQuotaExceeded(TestError()))
    }

    private static func partialFailure(_ itemErrors: [CKError]) -> CKError {
        let errorsByID = Dictionary(
            uniqueKeysWithValues: itemErrors.enumerated().map { index, error in
                (CKRecord.ID(recordName: "record-\(index)"), error as any Error)
            }
        )
        return CKError(.partialFailure, userInfo: [CKPartialErrorsByItemIDKey: errorsByID])
    }
}
