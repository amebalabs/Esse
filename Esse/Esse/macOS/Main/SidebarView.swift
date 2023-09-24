import EsseCore
import SwiftUI

struct SidebarView: View {
    var sidebarItems: [SidebarItem]
    @Binding var selectedFunction: TextFunction?
    @State private var selectedItem: SidebarItem?
    @State private var isExpanded: Bool = true
    @Binding var searchTerm: String

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(searchTerm.isEmpty ? sidebarItems : Storage.sharedInstance.filteredSidebarItems(searchTerm: searchTerm), id: \.self) { item in
                DisclosureGroup(item.title, isExpanded:$isExpanded) {
                    ForEach(item.children, id: \.self) { subItem in
                        Text(subItem.title)
                            .tag(subItem)
                            .contentShape(Rectangle())
                    }
                }
            }
        }.onChange(of: selectedItem) {
            selectedFunction = selectedItem?.textFunction
        }
        .onChange(of: searchTerm) {
            isExpanded = !searchTerm.isEmpty
        }
    }
}

#Preview {
    SidebarView(sidebarItems: Storage.sharedInstance.sidebarItems, selectedFunction: .constant(Storage.sharedInstance.pAllFunctions.first), searchTerm: .constant(""))
}
