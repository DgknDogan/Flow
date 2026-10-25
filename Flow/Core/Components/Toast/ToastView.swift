import SwiftUI

/// Dynamic Island'dan açılıyormuş gibi büyüyen toast kabı.
struct ToastView: View {

    var window: PassThroughWindow

    private var isExpanded: Bool {
        window.isPresented
    }

    var body: some View {
        GeometryReader { geo in
            let safeArea = geo.safeAreaInsets
            let size = geo.size

            let hasDynamicIsland = safeArea.top >= 59
            let dynamicIslandWidth: CGFloat = 120
            let dynamicIslandHeight: CGFloat = 36
            let topOffset: CGFloat = 11 + max(safeArea.top - 59, 0)
            let expandedWidth = size.width - 20
            let expandedHeight: CGFloat = hasDynamicIsland ? 90 : 70

            let scaleX: CGFloat = isExpanded ? 1 : (dynamicIslandWidth / expandedWidth)
            let scaleY: CGFloat = isExpanded ? 1 : (dynamicIslandHeight / expandedHeight)

            ZStack {
                ConcentricRectangle(corners: .concentric(minimum: .fixed(30)), isUniform: true)
                    .fill(.clear)
                    .glassEffect(
                        .clear.tint(.black),
                        in: ConcentricRectangle(corners: .concentric(minimum: .fixed(30)), isUniform: true)
                    )
                    .shadow(color: .black.opacity(0.6), radius: 10)
                    .overlay {
                        if let toast = window.toast {
                            ToastContentView(toast: toast, isExpanded: isExpanded, hasDynamicIsland: hasDynamicIsland)
                                .frame(width: expandedWidth, height: expandedHeight)
                                .scaleEffect(x: scaleX, y: scaleY)
                        }
                    }
                    .frame(
                        width: isExpanded ? expandedWidth : dynamicIslandWidth,
                        height: isExpanded ? expandedHeight : dynamicIslandHeight
                    )
                    .offset(y: hasDynamicIsland ? topOffset : (isExpanded ? safeArea.top : -80))
                    .opacity(hasDynamicIsland ? 1 : (isExpanded ? 1 : 0))
                    .animation(.linear(duration: 0.02).delay(isExpanded ? 0 : 0.28)) { content in
                        content
                            .opacity(hasDynamicIsland ? (isExpanded ? 1 : 0) : 1)
                    }
                    .geometryGroup()
                    .gesture(DragGesture().onEnded(dismissIfSwipedUp))
            }
            .animation(.bouncy(extraBounce: 0.1), value: isExpanded)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
        }
        .environment(\.locale, window.locale)
    }

    private func dismissIfSwipedUp(_ value: DragGesture.Value) {
        if value.translation.height < 0 {
            window.isPresented = false
        }
    }
}
