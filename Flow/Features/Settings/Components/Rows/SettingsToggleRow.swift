import SwiftUI

struct SettingsToggleRow: View {

    let icon: String
    let tint: Color
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            IconRow(icon: icon, tint: tint, title: title, subtitle: subtitle)
        }
    }
}
