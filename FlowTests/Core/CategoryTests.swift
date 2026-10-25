import Testing
import UIKit
@testable import Flow

@Suite("Categories")
@MainActor
struct CategoryTests {

    @Test func expenseCategoriesHaveUniqueNamesAndIcons() {
        assertWellFormed(ExpenseCategory.allCases)
    }

    @Test func incomeCategoriesHaveUniqueNamesAndIcons() {
        assertWellFormed(IncomeCategory.allCases)
    }

    @Test func everyCategoryFallsBackToOther() {
        #expect(ExpenseCategory.allCases.contains(.other))
        #expect(IncomeCategory.allCases.contains(.other))
    }

    @Test func transactionTypeExposesKindAndDetails() {
        let expense = TransactionType.expense(.travel)
        let income = TransactionType.income(.gift)

        #expect(expense.kind == .expense)
        #expect(income.kind == .income)
        #expect(expense.details.iconName == ExpenseCategory.travel.iconName)
        #expect(income.details.rawValue == IncomeCategory.gift.rawValue)
    }

    private func assertWellFormed<Category: CategoryProtocol>(_ categories: [Category]) {
        let names = categories.map { String(localized: $0.displayName) }
        let rawValues = categories.map(\.rawValue)
        let icons = categories.map(\.iconName)

        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Set(names).count == categories.count)
        #expect(Set(rawValues).count == categories.count)
        #expect(Set(icons).count == categories.count)
        for icon in icons {
            #expect(UIImage(systemName: icon) != nil, "Eksik SF Symbol: \(icon)")
        }
    }
}
