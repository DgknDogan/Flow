import Testing
import SwiftUI
@testable import Flow

/// Seçicilerde gösterilen enum'lar (`TitledOption`) ve para birimi bilgileri.
@Suite("Options")
@MainActor
struct OptionTests {

    @Test func titledOptionsHaveUniqueNonEmptyTitles() {
        assertTitles(TransactionKind.allCases)
        assertTitles(DateTabs.allCases)
        assertTitles(AppTheme.allCases)
        assertTitles(Currency.allCases)
    }

    @Test func currencyCodesAreValidISOCodes() {
        let codes = Currency.allCases.map(\.code)

        #expect(Set(codes).count == codes.count)
        for code in codes {
            #expect(Locale.commonISOCurrencyCodes.contains(code), "Geçersiz ISO kodu: \(code)")
        }
    }

    @Test func currencySymbolsAreNotEmpty() {
        #expect(Currency.allCases.allSatisfy { !$0.actualSymbol.isEmpty })
    }

    /// Kayıtlı tercihler bozulmasın diye ham değerler sabit kalmalı.
    @Test func persistedRawValuesStayStable() {
        #expect(Currency.dollar.rawValue == "dollarsign")
        #expect(Currency.franc.rawValue == "francsign")
        #expect(AppTheme.dark.rawValue == "dark")
    }

    @Test func themesMapToColorSchemes() {
        #expect(AppTheme.system.colorScheme == nil)
        #expect(AppTheme.light.colorScheme == .light)
        #expect(AppTheme.dark.colorScheme == .dark)
        for theme in AppTheme.allCases {
            #expect(UIImage(systemName: theme.symbol) != nil, "Eksik SF Symbol: \(theme.symbol)")
        }
    }

    @Test func dateTabsUseMatchingCalendarUnits() {
        #expect(DateTabs.month.chartUnit == .day)
        #expect(DateTabs.month.rangeUnit == .month)
        #expect(DateTabs.year.chartUnit == .month)
        #expect(DateTabs.year.rangeUnit == .year)
    }

    private func assertTitles<Option: TitledOption>(_ options: [Option]) {
        let titles = options.map { String(localized: $0.title) }
        #expect(titles.allSatisfy { !$0.isEmpty })
        #expect(Set(titles).count == options.count)
    }
}
