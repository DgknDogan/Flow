nonisolated enum KeypadKey: Hashable, Identifiable {
    case digit(Int)
    case decimalSeparator
    case delete

    var id: Self { self }

    /// Telefon tuş takımı düzeni: 1-9, ardından sil, 0 ve ondalık ayırıcı.
    static let layout: [KeypadKey] = (1...9).map(KeypadKey.digit) + [.delete, .digit(0), .decimalSeparator]
}
