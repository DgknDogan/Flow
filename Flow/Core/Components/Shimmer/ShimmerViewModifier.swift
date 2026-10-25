import SwiftUI

/// Yükleme yer tutucusu. Reduce Motion açıksa kayan parıltı yerine düz yer tutucu gösterilir.
struct ShimmerViewModifier: ViewModifier {

    @State private var isMoving = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let size = geo.size

                    Rectangle()
                        .fill(isDark ? .black.mix(with: .white, by: 0.2) : .gray.mix(with: .white, by: 0.5))

                    if !reduceMotion {
                        Rectangle()
                            .fill(highlight)
                            .frame(width: size.width / 2.5, height: size.height * 2)
                            .offset(x: isMoving ? size.width * 1.2 : -size.width * 1.2, y: -size.height / 2)
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isMoving)
                            .onAppear {
                                isMoving = true
                            }
                    }
                }
            }
            .mask {
                content
            }
    }

    private var isDark: Bool {
        colorScheme == .dark
    }

    private var highlight: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0), .white.opacity(isDark ? 0.2 : 0.5), .white.opacity(0)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerViewModifier())
    }
}
