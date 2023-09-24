import SwiftUI


@main
struct EsseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("Esse", id:"main") {
            MacMainView()
                .frame(minWidth: 600, minHeight: 400)
        }
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
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
