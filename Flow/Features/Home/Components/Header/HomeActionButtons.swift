import SwiftUI

/// Sağ üstteki ay seçici ve ekle/aramayı kapat butonları.
struct HomeActionButtons: View {

    let isSearching: Bool
    @Binding var selectedMonth: Int
    let onPrimaryAction: () -> Void

    @State private var isMonthPickerPresented = false
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                if !isSearching {
                    GlassIconButton(
                        title: "Choose Month",
                        systemImage: "calendar",
                        glassID: "calendar",
                        namespace: namespace,
                        action: showMonthPicker
                    )
                    .accessibilityIdentifier("monthPickerButton")
                    .popover(isPresented: $isMonthPickerPresented) {
                        MonthPickerList(selectedMonth: $selectedMonth, onSelect: hideMonthPicker)
                            .presentationCompactAdaptation(.popover)
                    }
                }

                GlassIconButton(
                    title: primaryActionTitle,
                    systemImage: isSearching ? "xmark" : "plus",
                    glassID: "primary",
                    namespace: namespace,
                    action: onPrimaryAction
                )
                .accessibilityIdentifier("homePrimaryButton")
            }
        }
        .animation(AppAnimation.search, value: isSearching)
    }

    private var primaryActionTitle: LocalizedStringKey {
        isSearching ? "Close Search" : "Add Transaction"
    }

    private func showMonthPicker() {
        isMonthPickerPresented = true
    }

    private func hideMonthPicker() {
        isMonthPickerPresented = false
    }
}
