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

#Preview {
    LibraryView()
}
