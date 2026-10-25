import SwiftUI

struct OnboardingPageIndicator: View {

    let currentStep: OnboardingStep

    var body: some View {
        HStack {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                let isCurrent = step == currentStep

                Circle()
                    .fill(isCurrent ? Color.accentColor : Color.gray)
                    .frame(width: isCurrent ? 12 : 8, height: isCurrent ? 12 : 8)
                    .animation(.spring, value: currentStep)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentStep.position) of \(OnboardingStep.allCases.count)")
    }
}
