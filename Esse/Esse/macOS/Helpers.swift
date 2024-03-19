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
    
    func filterFunctions(searchTerm: String) -> [TextFunction] {
        guard !searchTerm.isEmpty else {return []}
        let term = searchTerm.lowercased()
        return pAllFunctions.filter { $0.searchableText.score(word: term) > 0.4 }.sorted { $0.searchableText.score(word: term) > $1.searchableText.score(word: term) }
    }
    
    func filteredSidebarItems(searchTerm: String) -> [SidebarItem] {
        let functions = filterFunctions(searchTerm: searchTerm)
        
        var out: [SidebarItem] = []
        FunctionCategory.allCases.forEach { category in
            var parentItem = SidebarItem(title: category.rawValue, textFunction: nil)
            parentItem.children = functions.filter { $0.category == category }.map { SidebarItem(id: $0.id, title: $0.title, textFunction: $0) }
            if !parentItem.children.isEmpty {
                out.append(parentItem)
            }
        }
        return out
    }
}
