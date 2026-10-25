import Testing
import SwiftUI
@testable import Flow

@Suite("AppRouter")
@MainActor
struct AppRouterTests {

    @Test func firstLaunchStartsWithOnboarding() {
        TestDefaults.installIsolatedStore()
        #expect(AppRouter().appFlow == .onBoard)
    }

    @Test func returningUserStartsWithSplash() {
        TestDefaults.installIsolatedStore()
        UserDefaults.hasSeenAppIntroduction = true

        #expect(AppRouter().appFlow == .splash)
    }

    @Test func finishingOnboardingIsRememberedAndShowsMain() {
        TestDefaults.installIsolatedStore()
        let router = AppRouter()

        router.finishOnboarding()

        #expect(router.appFlow == .main)
        #expect(UserDefaults.hasSeenAppIntroduction)
    }

    @Test func switchToMainShowsMain() {
        TestDefaults.installIsolatedStore()
        let router = AppRouter()

        router.switchToMain()

        #expect(router.appFlow == .main)
    }

    @Test func startsOnHomeWithoutSheetOrNavigation() {
        TestDefaults.installIsolatedStore()
        let router = AppRouter()

        #expect(router.selectedTab == .home)
        #expect(!router.isAddTransactionPresented)
        #expect(router.homePath.isEmpty)
        #expect(router.detailsPath.isEmpty)
        #expect(router.settingsPath.isEmpty)
        #expect(router.assistantPath.isEmpty)
    }
}
