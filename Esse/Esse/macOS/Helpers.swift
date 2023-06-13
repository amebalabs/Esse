import EsseCore

extension Storage {
    var sidebarItems: [SidebarItem] {
        var out: [SidebarItem] = []
        FunctionCategory.allCases.forEach { category in
            var parentItem = SidebarItem(title: category.rawValue, textFunction: nil)
            parentItem.children = pAllFunctions.filter { $0.category == category }.map { SidebarItem(id: $0.id, title: $0.title, textFunction: $0) }
            out.append(parentItem)
        }
        return out
    }
}
