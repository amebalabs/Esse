import SwiftUI
import UniformTypeIdentifiers

struct EsseDocument: FileDocument {
    var text: AttributedString

    init(text: AttributedString = AttributedString("")) {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.plainText] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = AttributedString(string)
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let string = String(text.characters)
        guard let data = string.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return .init(regularFileWithContents: data)
    }
}
