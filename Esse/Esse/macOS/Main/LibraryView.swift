import SwiftUI
import EsseCore

struct SidebarItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let title: String
    var children: [SidebarItem] = []
    let isExpanded: Bool = false
    let textFunction: TextFunction?
}

struct LibraryView: View {
    @State var searchTerm = ""
    @State var highlightedFunction: TextFunction? = nil
    @State var selectedFunction: TextFunction?
    
    let sidebarItems: [SidebarItem] = Storage.sharedInstance.sidebarItems
    
    var body: some View {
        NavigationView {
            SidebarView(sidebarItems: sidebarItems, selectedFunction: $selectedFunction, highlightedFunction: $highlightedFunction)
                .searchable(text: $searchTerm, placement: .sidebar)
            InspectorView(textFunction: $selectedFunction)
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
        }
        .navigationTitle("Esse Library")
    }
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

func openLibraryView() {
    let libraryView = LibraryView()
    let hostingController = NSHostingController(rootView: libraryView)
    let newWindow = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )
    newWindow.contentView = hostingController.view
    newWindow.makeKeyAndOrderFront(nil)
}

#Preview {
    LibraryView()
}
