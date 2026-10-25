import SwiftUI

/// `MainRoutes` hedeflerini her sekmenin NavigationStack'ine bir kez kaydeder.
struct MainRouteDestinations: ViewModifier {

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: MainRoutes.self) { route in
                switch route {
                case .profile: ProfileView()
                case .notifications: NotificationSettingsView()
                case .currency: CurrencySettingsView()
                case .budget: BudgetSettingsView()
                case .appearance: AppearanceSettingsView()
                case .language: LanguageSettingsView()
                case .security: SecuritySettingsView()
                case .iCloudSync: ICloudSyncSettingsView()
                case .about: AboutView()
                case .legal(let document): LegalDocumentView(document: document)
                }
            }
    }
}

extension View {
    func mainViewRoute() -> some View {
        modifier(MainRouteDestinations())
    }
}
