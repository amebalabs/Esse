import SwiftUI

struct LibraryCommands: Commands {
    @AppStorage("dualPaneModeEnabled") var isMultiEditorMode: Bool = false
    @Environment(\.openWindow) private var openWindow
    
    var body: some Commands {
        CommandMenu("Library") {
            Button("Command Palette...", action: {
                NotificationCenter.default.post(name: .showCommandPallete, object: nil)
            }).keyboardShortcut("P", modifiers: [.command, .shift])

            Button("Run", action: {
                NotificationCenter.default.post(name: .runFunctions, object: nil)
            }).keyboardShortcut("R", modifiers: [.command])
                
            Divider()
            
            Button("Show Library...", action: {
                openWindow(id: "library")
            }).keyboardShortcut("L", modifiers: [.command, .shift])
            
            Button("Open Scripts Folder", action: {
                let fileManager = FileManager.default
                if let iCloudURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    NSWorkspace.shared.open(iCloudURL)
                }
            })
            
            Button("Get More Scripts", action: {
                NSWorkspace.shared.open(URL(string: "https://github.com/amebalabs/Esse/tree/master/Scripts")!)
            })
        }
    }
}

struct CustomViewCommands: Commands {
    @AppStorage("dualPaneModeEnabled") var isMultiEditorMode: Bool = false
    
    var body: some Commands {
        CommandGroup(after: CommandGroupPlacement.toolbar) {
            Button("Standard Mode", action: {
                isMultiEditorMode = false
            })
            .keyboardShortcut("1", modifiers: [.command])
            
            Button("Two-pane Mode", action: {
                isMultiEditorMode = true
            })
            .keyboardShortcut("2", modifiers: [.command])
            
            Divider()
        }
    }
}


struct CustomFileCommands: Commands {
    @AppStorage("userText") private var sourceText: String = ""
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(after: CommandGroupPlacement.newItem) {
            Button("New", action: {
                newWithText(text: "")
            })
            .keyboardShortcut("N", modifiers: [.command])
            
            Button("New from Clipboard", action: {
                guard let clipboardText = NSPasteboard.general.string(forType: .string) else {
                    newWithText(text: "")
                    return
                }
                newWithText(text: clipboardText)
            })
            .keyboardShortcut("N", modifiers: [.command, .shift])
            .disabled(!(NSPasteboard.general.types?.contains(.string) ?? false))
            
        }
    }
    
    func openWindowIfNeeded() {
        guard !NSApp.windows.contains(where: {$0.identifier?.rawValue.starts(with: "main") ?? false}) else {return}
        openWindow(id: "main")
    }
    
    func newWithText(text: String) {
        sourceText = text
        openWindowIfNeeded()
    }
}
