import Testing
@testable import Flow

@Suite("SequentialCase")
struct SequentialCaseTests {

    @Test func formStepsMoveForwardInOrder() {
        #expect(TransactionFormStep.category.next == .date)
        #expect(TransactionFormStep.date.next == .note)
        #expect(TransactionFormStep.note.next == .amount)
        #expect(TransactionFormStep.amount.next == nil)
    }

    @Test func formStepsMoveBackInOrder() {
        #expect(TransactionFormStep.amount.previous == .note)
        #expect(TransactionFormStep.note.previous == .date)
        #expect(TransactionFormStep.date.previous == .category)
        #expect(TransactionFormStep.category.previous == nil)
    }

    @Test func positionsStartAtOne() {
        #expect(TransactionFormStep.allCases.map(\.position) == [1, 2, 3, 4])
        #expect(OnboardingStep.allCases.map(\.position) == [1, 2, 3])
    }

    @Test func onboardingEndsAfterInsights() {
        #expect(OnboardingStep.tracking.next == .budgeting)
        #expect(OnboardingStep.budgeting.next == .insights)
        #expect(OnboardingStep.insights.next == nil)
    }
}
