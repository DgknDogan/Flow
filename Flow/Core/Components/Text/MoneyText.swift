import SwiftUI

/// Tutarı seçili para birimiyle, cihazın bölge ayarına göre gösterir.
/// Para birimi ortamdaki `AppState`'ten okunur; çağıran görünümün ayrıca okuması gerekmez.
struct MoneyText: View {

    private let amount: Decimal
    private let showsSign: Bool

    @Environment(AppState.self) private var appState

    /// - Parameter showsSign: `true` ise pozitif tutarlar da işaretli gösterilir (+€10, -€10).
    init(_ amount: Decimal, showsSign: Bool = false) {
        self.amount = amount
        self.showsSign = showsSign
    }

    /// Grafik ve limit gibi `Double` tutarlar için; para birimi hassasiyetine yuvarlanır.
    init(_ amount: Double, showsSign: Bool = false) {
        self.init(Decimal(amount), showsSign: showsSign)
    }

    var body: some View {
        Text(amount, format: format)
    }

    private var format: Decimal.FormatStyle.Currency {
        let style = Decimal.FormatStyle.Currency.currency(appState.currency)
        return showsSign ? style.sign(strategy: .always()) : style
    }
}

#Preview {
    VStack {
        MoneyText(Decimal(1234.5))
        MoneyText(Decimal(-12), showsSign: true)
    }
    .environment(AppState())
}
