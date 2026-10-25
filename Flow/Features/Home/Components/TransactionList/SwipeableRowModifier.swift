import SwiftUI

/// Satırı yalnızca sola kaydırmaya izin verir; eşik aşılırsa silme butonu açık kalır.
struct SwipeableRowModifier: ViewModifier {

    private enum Constants {
        static let swipeThreshold = 40.0
        static let swipeRevealWidth = 80.0
    }

    @Binding var horizontalDragAmount: Double

    func body(content: Content) -> some View {
        content
            .gesture(
                HorizontalPanGesture(
                    onChanged: handleDragChanged,
                    onEnded: handleDragEnded
                )
            )
    }

    private func handleDragChanged(_ xDrag: Double) {
        // Zaten sola kaydırılmışsa ve kullanıcı sağa çekiyorsa kapat.
        if horizontalDragAmount < 0 && xDrag > 0 {
            withAnimation {
                horizontalDragAmount = .zero
            }
            return
        }

        guard xDrag <= 0 else { return }

        withAnimation {
            horizontalDragAmount = xDrag
        }
    }

    private func handleDragEnded(_ xDrag: Double) {
        guard xDrag <= 0 else {
            withAnimation {
                horizontalDragAmount = .zero
            }
            return
        }

        withAnimation {
            horizontalDragAmount = abs(xDrag) > Constants.swipeThreshold ? -Constants.swipeRevealWidth : .zero
        }
    }
}

extension View {
    func swipeableRow(horizontalDragAmount: Binding<Double>) -> some View {
        modifier(SwipeableRowModifier(horizontalDragAmount: horizontalDragAmount))
    }
}
