import SwiftUI

struct OnboardingView: View {

    @Environment(AppRouter.self) private var router

    @State private var currentStep: OnboardingStep = .tracking

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip", action: finish)
                    .padding(.trailing)
            }

            TabView(selection: $currentStep) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    OnboardingItemView(step: step)
                        .tag(step)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring, value: currentStep)
            .allowsHitTesting(false)

            OnboardingPageIndicator(currentStep: currentStep)

            PrimaryButton(action: advance) {
                Text(currentStep.next == nil ? "Start" : "Next")
            }
            .padding()
        }
    }

    private func advance() {
        if let next = currentStep.next {
            currentStep = next
        } else {
            finish()
        }
    }

    private func finish() {
        router.finishOnboarding()
    }
}

#Preview {
    OnboardingView()
        .environment(AppRouter())
}
