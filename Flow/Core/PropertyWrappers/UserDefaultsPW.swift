import Foundation

/// Değeri `UserDefaults.appStore`'da saklar; `nil` atanırsa anahtarı siler.
@propertyWrapper
struct UserDefaultsPW<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            UserDefaults.appStore.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.appStore.removeObject(forKey: key)
            } else {
                UserDefaults.appStore.set(newValue, forKey: key)
            }
        }
    }
}

extension UserDefaultsPW where Value: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(key: key, defaultValue: nil)
    }
}
