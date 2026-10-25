import SwiftUI

struct NoteInputView: View {

    @Binding var noteText: String
    let onBack: () -> Void

    private let characterLimit = 500

    var body: some View {
        VStack {
            SheetHeader("Add Note", action: onBack)

            TextField("Add a note", text: $noteText, axis: .vertical)
                .lineLimit(4...8)
                .accessibilityIdentifier("noteField")
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: AppRadius.card))
                .onChange(of: noteText) { _, newValue in
                    if newValue.count > characterLimit {
                        noteText = String(newValue.prefix(characterLimit))
                    }
                }

            Text("\(noteText.count)/\(characterLimit)")
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(noteText.count >= characterLimit ? Color.red : Color.secondary)
                .padding(.trailing, 5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityLabel("\(noteText.count) of \(characterLimit) characters")
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var note = ""
    NoteInputView(noteText: $note) { }
        .padding()
}
