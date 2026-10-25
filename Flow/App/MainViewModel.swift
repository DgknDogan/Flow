import Foundation
import Observation
import SwiftData

@Observable
final class MainViewModel {
    var transactions: [Transaction] = []
    var viewState: ViewState = .loading

    /// Getirme eşzamanlı olduğu için ara bir "yükleniyor" durumu yok; ilk açılışta `.loading` ile başlar.
    func loadTransactions(in context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<TransactionEntity>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            transactions = try context.fetch(descriptor).map { $0.toDomain() }
            viewState = .success
        } catch {
            print("Failed to load transactions: \(error)")
            viewState = .error
        }
    }

    /// Silme başarısız olursa hata fırlatır ve listeye dokunmaz; böylece satır geri getirilebilir.
    func deleteTransaction(_ transaction: Transaction, in context: ModelContext) throws {
        do {
            context.delete(try context.transactionEntity(id: transaction.id))
            try context.save()
        } catch PersistenceError.notFound {
            // Depoda zaten yok (ör. başka cihazda silinmiş); sadece listeden çıkarılır.
        } catch {
            context.rollback()
            throw error
        }
        transactions.removeAll { $0.id == transaction.id }
    }

    func appendTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
    }

    func replaceTransaction(_ transaction: Transaction) {
        guard let idx = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            transactions.insert(transaction, at: 0)
            return
        }
        transactions[idx] = transaction
    }
}
