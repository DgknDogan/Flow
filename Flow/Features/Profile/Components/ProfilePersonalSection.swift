import SwiftUI

struct ProfilePersonalSection: View {

    let onEditName: () -> Void

    @Environment(AppState.self) private var appState

    var body: some View {
        Section("Personal") {
            Button(action: onEditName) {
                IconRow(icon: "person.text.rectangle.fill", tint: .blue, title: "Name") {
                    Text(appState.userName, placeholder: "Add")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
