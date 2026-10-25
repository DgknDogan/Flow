/// Uygulamayı test moduna geçiren başlatma argümanları.
/// Adlar uygulamadaki `UITestLaunch` ile aynı olmalı.
enum LaunchArgument {
    /// Tercihleri her açılışta boşaltılan ayrı bir depoya, işlemleri bellek içi veritabanına yönlendirir.
    static let uiTesting = "-ui-testing"
    /// Bugüne tarihli üç örnek işlem ekler: Dining Out 120, Transportation 45, Salary 5000.
    static let seedTransactions = "-ui-testing-seed"
    /// Onboarding'i atlayıp splash ile ana ekrana geçer.
    static let skipOnboarding = "-ui-testing-skip-onboarding"
}
