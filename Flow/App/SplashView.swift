import SwiftUI

struct SplashView: View {

    @Environment(AppRouter.self) private var router
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Uygulama kilidi açılana kadar `false`; animasyon Face ID isteminin arkasında boşa oynamasın diye bekler.
    var isReady = true

    @State private var loadingProgress = 0.0
    @State private var isExpanded = false

    var body: some View {
        // Simge tüm ekranı kaplayacak kadar büyüdüğü için kapsayıcının tam boyutu gerekiyor.
        GeometryReader { geo in
            let size = geo.size

            VStack {
                Image("flowIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(20)
                    .frame(
                        width: isExpanded ? size.width : 140,
                        height: isExpanded ? size.height : 140
                    )
                    .background(.green.gradient.secondary)
                    .clipShape(.rect(cornerRadius: isExpanded ? 0 : 70))
                    .padding(loadingProgress == 1 ? 0 : 20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 90)
                            .trim(from: 0, to: loadingProgress)
                            .fill(.clear)
                            .stroke(.green.gradient.secondary, style: .init(lineWidth: isExpanded ? 0 : 3))
                            .opacity(isExpanded ? 0 : 1)
                    }
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .task(id: isReady) {
            guard isReady else { return }
            animateIn()
            guard (try? await Task.sleep(for: .seconds(2))) != nil else { return }
            router.switchToMain()
        }
    }

    /// Önce halka dolar, bittiğinde simge ekranı kaplar. Reduce Motion açıksa büyüme atlanır.
    private func animateIn() {
        withAnimation(.smooth(duration: 1, extraBounce: 0)) {
            loadingProgress = 1
        } completion: {
            guard !reduceMotion else { return }
            withAnimation(.smooth(duration: 0.8, extraBounce: 0)) {
                isExpanded = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppRouter())
}
