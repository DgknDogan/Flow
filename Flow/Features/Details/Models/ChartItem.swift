import Foundation

nonisolated struct ChartItem: Identifiable, Equatable {
    let date: Date
    let amount: Double

    var id: Date { date }
}
