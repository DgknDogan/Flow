import SwiftUI

/// İçeriğinin yüksekliğine göre detent'ini ayarlayan sheet kabı.
struct DynamicSheet<Content: View>: View {

    @ViewBuilder var content: Content

    @State private var sheetHeight = 0.0

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            content
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    updateHeight(for: newValue.height)
                }
        }
        .modifier(SheetHeightModifier(height: sheetHeight))
        .presentationBackground {
            colorScheme == .dark ? Color.black.mix(with: .white, by: 0.2) : Color.white
        }
    }

    /// İlk ölçümde animasyonsuz, sonraki adım değişimlerinde yumuşak geçişle uygulanır.
    private func updateHeight(for contentHeight: Double) {
        let newHeight = min(contentHeight, maxSheetHeight)
        if sheetHeight == .zero {
            sheetHeight = newHeight
        } else {
            withAnimation(AppAnimation.stepTransition) {
                sheetHeight = newHeight
            }
        }
    }

    /// Ekranın üstünde 100pt boşluk kalacak en büyük yükseklik.
    private var maxSheetHeight: Double {
        let screenHeight = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.height
        return (screenHeight ?? .infinity) - 100
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            DynamicSheet {
                Text("Hey")
                    .frame(height: 400)
            }
        }
}
