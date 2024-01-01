import SwiftUI


@main
struct EsseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("showMenubarExtra") private var showMenuBarExtra = true

    var body: some Scene {
        DocumentGroup(newDocument: EsseDocument()) { file in
            MacMainView(document: file.$document)
        }
//        WindowGroup("Esse", id:"main") {
//            MacMainView()
//                .frame(minWidth: 600, minHeight: 400)
//        }
        .commands {
//            CommandGroup(replacing: .newItem, addition: { })
            CustomFileCommands()
            CustomViewCommands()
            LibraryCommands()
        }
        Window("Library", id:"library") {
            LibraryView()
        }
        Settings {
            SettingsView()
        }
    }
}
