import SwiftUI

struct AmountInputView: View {

    @Binding var amount: String
    let onBack: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var amountFontSize = 50.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SheetHeader("Set Amount", action: onBack)

            Text(AmountEntry.displayText(for: amount))
                .font(.system(size: amountFontSize, weight: .bold))
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityIdentifier("amountDisplay")

            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 15) {
                ForEach(KeypadKey.layout) { key in
                    KeypadButton(key: key) {
                        press(key)
                    }
                }
            }
            .padding(.horizontal, -15)
        }
    }

    private func press(_ key: KeypadKey) {
        withAnimation(.snappy) {
            amount = AmountEntry.applying(key, to: amount)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var amount = "42.5"
    AmountInputView(amount: $amount) { }
        .padding()
}
