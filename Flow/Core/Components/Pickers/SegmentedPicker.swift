import SwiftUI

/// Başlıklı enum'lar için segmented seçici; seçenekler `allCases` sırasıyla gösterilir.
struct SegmentedPicker<Option: TitledOption & CaseIterable>: View {

    let title: LocalizedStringKey
    @Binding var selection: Option

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Array(Option.allCases), id: \.self) { option in
                Text(option.title)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var kind: TransactionKind = .expense
    SegmentedPicker(title: "Transaction Type", selection: $kind)
        .padding()
}
