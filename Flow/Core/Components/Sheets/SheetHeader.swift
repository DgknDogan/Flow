import SwiftUI

/// Sheet adımlarının başlığı: solda geri/kapat butonu, yanında başlık.
/// Görünen daire 28pt kalır, dokunma alanı 44pt'dir.
struct SheetHeader: View {

    private let title: LocalizedStringKey
    private let buttonTitle: LocalizedStringKey
    private let systemImage: String
    private let action: () -> Void

    init(
        _ title: LocalizedStringKey,
        buttonTitle: LocalizedStringKey = "Back",
        systemImage: String = "chevron.backward",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.buttonTitle = buttonTitle
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: action) {
                Label(buttonTitle, systemImage: systemImage)
                    .labelStyle(.iconOnly)
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(.gray.gradient, in: .circle)
                    .frame(width: AppLayout.minimumTapSize, height: AppLayout.minimumTapSize)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .padding(.leading, -8)

            Text(title)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
        }
    }
}

#Preview {
    SheetHeader("Set Amount") { }
        .padding()
}
