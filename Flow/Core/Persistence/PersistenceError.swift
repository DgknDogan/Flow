import Foundation

nonisolated enum PersistenceError: Error, Sendable, LocalizedError {
    case notFound

    var errorDescription: String? {
        switch self {
        case .notFound: String(localized: "The requested item was not found.")
        }
    }
}
