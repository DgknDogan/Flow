import SwiftUI

enum CategorySelectionMode {
    /// Yeni işlemde gelir/gider seçilebilir.
    case picker(Binding<TransactionKind>)
    /// Düzenlemede işlemin türü sabittir.
    case fixed(TransactionKind)
}
