import SwiftUI

/// Seçenekleri tek bir liste hücresinde çizer; böylece seçim işareti satırlar arasında
/// `matchedGeometryEffect` ile kayarak yer değiştirebilir (ayrı List satırlarında bu animasyon çalışmaz).
struct SettingsSelectionGroup<Option: Hashable, Leading: View>: View {

    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> LocalizedStringResource
    @ViewBuilder let leading: (Option) -> Leading

    @Namespace private var checkmarkNamespace
    /// Animasyon sürerken gösterilen seçim. Dil ya da tema gibi bazı seçimler bütün ekranı yeniden
    /// çizdirir; bu sırada kayan işaretin yanında ikinci bir işaret köşeden uçarak gelir. Bu yüzden
    /// seçim, işaret yerine oturduktan sonra `selection`'a yazılır.
    @State private var pendingSelection: Option?

    private var shownSelection: Option {
        pendingSelection ?? selection
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    select(option)
                } label: {
                    SettingsSelectionRow(
                        title: title(option),
                        isSelected: shownSelection == option,
                        showsDivider: option != options.last,
                        namespace: checkmarkNamespace
                    ) {
                        leading(option)
                    }
                }
                .buttonStyle(.plain)
                .accessibilitySelected(shownSelection == option)
            }
        }
        .listRowInsets(EdgeInsets())
        .sensoryFeedback(.selection, trigger: shownSelection)
    }

    private func select(_ option: Option) {
        guard shownSelection != option else { return }
        withAnimation(AppAnimation.checkmark) {
            pendingSelection = option
        } completion: {
            // Arada başka bir seçenek seçildiyse onun animasyonu bitince yazılır.
            guard pendingSelection == option else { return }
            selection = option
            pendingSelection = nil
        }
    }
}

extension SettingsSelectionGroup where Option: TitledOption & CaseIterable {

    /// Başlıklı enum'ların tüm durumlarını `title` ile listeler.
    init(selection: Binding<Option>, @ViewBuilder leading: @escaping (Option) -> Leading) {
        self.init(options: Array(Option.allCases), selection: selection, title: \.title, leading: leading)
    }
}
