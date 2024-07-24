import Cocoa
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var documentController: DocumentController!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        @AppStorage("appearance") var appearance: AppearanceOptions = .System
        appearance.applyAppearance()
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = true
        documentController = DocumentController()
        DispatchQueue.main.async {
            if NSDocumentController.shared.documents.isEmpty {
                self.documentController.createAndOpenDefaultDocument()
            }
        }
    }
}

