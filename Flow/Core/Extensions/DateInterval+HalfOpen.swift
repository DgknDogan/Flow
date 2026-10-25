import Foundation

nonisolated extension DateInterval {

    /// `contains(_:)` bitişi de kapsar; dönemler art arda geldiği için bitiş anı bir sonraki
    /// döneme aittir. Bu yüzden yarı açık aralık [start, end) kullanılır.
    func containsHalfOpen(_ date: Date) -> Bool {
        start <= date && date < end
    }
}
