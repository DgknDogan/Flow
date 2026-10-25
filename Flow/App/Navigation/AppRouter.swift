import SwiftUI

@Observable
final class AppRouter {

    private static let flowAnimation: Animation = .easeInOut(duration: 0.4)

    var homePath = NavigationPath()
    var detailsPath = NavigationPath()
    var settingsPath = NavigationPath()
    var assistantPath = NavigationPath()

    var appFlow: AppFlow = .onBoard
    var selectedTab: Tabs = .home

    /// İşlem ekleme sheet'i `MainView`'da durur; böylece her sekmeden sekme değiştirmeden açılabilir.
    var isAddTransactionPresented = false

    init() {
        appFlow = UserDefaults.hasSeenAppIntroduction ? .splash : .onBoard
    }

    func switchToMain() {
        withAnimation(Self.flowAnimation) {
            appFlow = .main
        }
    }

    func finishOnboarding() {
        UserDefaults.hasSeenAppIntroduction = true
        switchToMain()
    }
}
