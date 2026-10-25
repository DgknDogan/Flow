import SwiftUI
import UniformTypeIdentifiers

/// `fileExporter` ile Dosyalar'a kaydedilen CSV dosyası. Başındaki BOM, Excel'in metni UTF-8
/// olarak okumasını (Türkçe karakterlerin bozulmamasını) sağlar.
nonisolated struct CSVDocument: FileDocument {

    static let readableContentTypes: [UTType] = [.commaSeparatedText]

    let text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(("\u{FEFF}" + text).utf8))
    }
}
