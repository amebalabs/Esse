import SwiftUI

@main
struct EsseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("showMenubarExtra") private var showMenuBarExtra = true

    var body: some Scene {
        DocumentGroup(newDocument: EsseDocument()) { file in
            MacMainView(document: file.$document)
        }
        .commands {
            CustomFileCommands()
            CustomViewCommands()
            LibraryCommands()
        }
        Window("Library", id: "library") {
            LibraryView()
        }
        Settings {
            SettingsView()
        }
    }
}

class DocumentController: ObservableObject {
    func createAndOpenDefaultDocument() {
        let document = EsseDocument()
        let documentURL = getAppSupportDirectory().appendingPathComponent("Esse.txt")
        do {
            let data = String(document.text.characters).data(using: .utf8)!
            try data.write(to: documentURL)
            NSDocumentController.shared.openDocument(withContentsOf: documentURL, display: true) { _, _, _ in }
        } catch {
            print("Failed to create default document: \(error)")
        }
    }

    private func getAppSupportDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDirectory = paths[0]

        if !FileManager.default.fileExists(atPath: appSupportDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create Application Support directory: \(error)")
            }
        }

        return appSupportDirectory
    }
}
