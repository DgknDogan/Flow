/// `allCases` sırasıyla ilerleyen adımlar (form adımları, onboarding sayfaları).
nonisolated protocol SequentialCase: CaseIterable, Equatable {}

nonisolated extension SequentialCase {

    /// Sıradaki durum; son durumdaysa `nil`.
    var next: Self? {
        neighbor(offset: 1)
    }

    /// Önceki durum; ilk durumdaysa `nil`.
    var previous: Self? {
        neighbor(offset: -1)
    }

    /// 1'den başlayan sıra numarası (ör. "Page 2 of 3").
    var position: Int {
        (Array(Self.allCases).firstIndex(of: self) ?? 0) + 1
    }

    private func neighbor(offset: Int) -> Self? {
        let cases = Array(Self.allCases)
        guard let index = cases.firstIndex(of: self) else { return nil }
        let target = index + offset
        return cases.indices.contains(target) ? cases[target] : nil
    }
}
