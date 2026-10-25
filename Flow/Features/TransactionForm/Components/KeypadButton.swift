import SwiftUI

struct KeypadButton: View {

    let key: KeypadKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                switch key {
                case .digit(let digit):
                    Text(digit, format: .number)
                case .decimalSeparator:
                    Text(verbatim: Locale.current.decimalSeparator ?? ".")
                        .accessibilityLabel("Decimal separator")
                case .delete:
                    Label("Delete", systemImage: "delete.left")
                        .labelStyle(.iconOnly)
                }
            }
            .font(.title2.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 60)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
