import SwiftUI

struct OnboardingItemView: View {

    let step: OnboardingStep

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                Image(step.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .zIndex(10)

                Circle()
                    .stroke(step.color.opacity(0.3), lineWidth: 3)
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.2 : 0.95)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        isAnimating ? .easeInOut(duration: 2).repeatForever(autoreverses: false) : .default,
                        value: isAnimating
                    )
            }
            .accessibilityHidden(true)
            .padding(.bottom)

            Text(step.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.bottom)

            Text(step.subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .task {
            await startPulse()
        }
        .onDisappear {
            isAnimating = false
        }
    }

    /// Halka sayfa açıldıktan kısa süre sonra nabız gibi atmaya başlar; Reduce Motion açıksa durağan kalır.
    private func startPulse() async {
        isAnimating = false
        guard !reduceMotion else { return }
        guard (try? await Task.sleep(for: .milliseconds(200))) != nil else { return }
        isAnimating = true
    }
}
