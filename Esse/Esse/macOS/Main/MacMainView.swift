#if os(macOS)
    import DSFQuickActionBar
#endif
import EsseCore
import SwiftUI

struct SidebarItem: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let title: String
    var children: [SidebarItem] = []
    let isExpanded: Bool = false
    let textFunction: TextFunction?
}

struct MacMainView: View {
    @State private var editableText: String = ""
    @State private var nonEditableText: String = ""

    @State var searchTerm = ""
    @State var visible = false

    @State private var insectorPresented = false
    @State private var isMultiEditorMode: Bool = false

    let sidebarItems: [SidebarItem] = Storage.sharedInstance.sidebarItems

    @State var highlightedFunction: TextFunction? = nil
    @State var selectedFunction: TextFunction?
    @State var selectedFunctions: [TextFunction] = []

    var body: some View {
        NavigationView {
            SidebarView(sidebarItems: sidebarItems, selectedFunction: $selectedFunction, highlightedFunction: $highlightedFunction)
                .searchable(text: $searchTerm, placement: .sidebar)
                .listStyle(SidebarListStyle())

            VStack {
                GeometryReader { geometry in
                    if !isMultiEditorMode {
                        TextEditor(text: $editableText)
                            .scrollIndicators(ScrollIndicatorVisibility.never)
                            .padding(2)
                            .font(.body)
                    } else {
                        HStack {
                            TextEditor(text: $editableText)
                                .frame(width: geometry.size.width / 2)
                                .onChange(of: editableText) { _, value in
                                    self.nonEditableText = selectedFunctions.run(value: value)
                                }
                                .scrollIndicators(ScrollIndicatorVisibility.never)
                                .padding(2)
                                .font(.body)

                            TextEditor(text: $nonEditableText)
                                .multilineTextAlignment(.leading)
                                .frame(width: geometry.size.width / 2)
                                .scrollIndicators(ScrollIndicatorVisibility.never)
                                .padding(2)
                                .font(.body)
                        }
                    }
                }
                .onChange(of: selectedFunction) { _, value in
                    if isMultiEditorMode, let value {
                        selectedFunctions.append(value)
                    } else {
                        editableText = value?.run(editableText) ?? ""
                    }
                }
                .onChange(of: selectedFunctions) { _, value in
                    if isMultiEditorMode {
                        self.nonEditableText = value.run(value: self.editableText)
                    }
                }
                .onChange(of: searchTerm) { _, value in
                    print("Search term: \(value)")
                }

                if isMultiEditorMode {
                    FooterView(footerItems: $selectedFunctions)
                }

                #if os(macOS)
                    QuickActionBar<TextFunction, FilterCellView>(
                        location: .window,
                        visible: $visible,
                        showKeyboardShortcuts: true,
                        requiredClickCount: .single,
                        searchTerm: $searchTerm,
                        selectedItem: $selectedFunction,
                        placeholderText: "Quick Search",
                        itemsForSearchTerm: self.quickOpenFilter,
                        viewForItem: { textFunction, _ in
                            FilterCellView(textFunction: textFunction)
                        }
                    )
                #endif
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
                ToolbarItem {
                    Toggle(isOn: $isMultiEditorMode) {
                        Label("Editor Mode", systemImage: "rectangle.split.2x1")
                    }
                    .toggleStyle(.automatic)
                }
                ToolbarItem {
                    Button(action: {
                        visible = true
                    }) {
                        Image(systemName: "command")
                    }
                    .keyboardShortcut("o", modifiers: [.command, .shift])
                }
            }
            .inspector(isPresented: $insectorPresented) {
                InspectorView(textFunction: $highlightedFunction)
                    .inspectorColumnWidth(min: 300, ideal: 400, max: 500)
                    .toolbar {
                        Spacer()
                        Button {
                            insectorPresented.toggle()
                        } label: {
                            Label("Toggle Inspector", systemImage:
                                "info.circle")
                        }
                    }
            }
        }
    }

    private func toggleSidebar() {
        #if os(macOS)
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }

    #if os(macOS)
        private func quickOpenFilter(_ task: DSFQuickActionBar.SearchTask) {
            var results: [TextFunction] = []
            if $searchTerm.wrappedValue.count > 0 {
                results = Storage.sharedInstance.pAllFunctions.filter { $0.searchableText.score(word: searchTerm) > 0.4 }.sorted { $0.searchableText.score(word: searchTerm) > $1.searchableText.score(word: searchTerm) }
            } else {
                results = Storage.sharedInstance.pAllFunctions
            }
            results = results.filter { !selectedFunctions.contains($0) }
            task.complete(with: results)
        }
    #endif
}

#Preview {
    MacMainView()
        .frame(width: 700, height: 500)
}
