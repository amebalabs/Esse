import EsseCore
import SwiftUI

struct SidebarView: View {
    var sidebarItems: [SidebarItem]
    @Binding var selectedFunction: TextFunction?
    @Binding var highlightedFunction: TextFunction?
    @State private var selectedItem: SidebarItem?

    var body: some View {
        List(selection: $selectedItem) {
            ForEach(sidebarItems, id: \.self) { item in
                DisclosureGroup(item.title) {
                    ForEach(item.children, id: \.self) { subItem in
                        Text(subItem.title)
                            .tag(subItem)
                            .gesture(TapGesture(count: 2).onEnded {
                                if let textFunction = subItem.textFunction {
                                    selectedFunction = textFunction
                                }
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                selectedItem = subItem
                                highlightedFunction = subItem.textFunction
                            })
                    }
                }
            }
        }
    }
}

#Preview {
    SidebarView(sidebarItems: Storage.sharedInstance.sidebarItems, selectedFunction: .constant(Storage.sharedInstance.pAllFunctions.first), highlightedFunction: .constant(Storage.sharedInstance.pAllFunctions.first))
}
