import Foundation

/// `RawRepresentable` değeri ham değeriyle `UserDefaults.appStore`'da saklar.
/// Kayıtlı ham değer tanınmazsa varsayılana döner.
@propertyWrapper
struct UserDefaultsRawPW<Value: RawRepresentable> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            guard let rawValue = UserDefaults.appStore.object(forKey: key) as? Value.RawValue else {
                return defaultValue
            }
            return Value(rawValue: rawValue) ?? defaultValue
        }
        set {
            UserDefaults.appStore.set(newValue.rawValue, forKey: key)
        }
    }
}
