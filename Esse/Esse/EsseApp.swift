import SwiftUI

@main
struct EsseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
        #if os(iOS)
            Text("Hi")
        #else
            MacMainView()
        #endif
        }.commands {
            SidebarCommands()
        }
    }
}
