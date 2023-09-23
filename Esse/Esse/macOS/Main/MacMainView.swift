#if os(macOS)
import DSFQuickActionBar
import STTextViewUI
import STTextView
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
    @State private var selection: NSRange?

    @State var searchTerm = ""
    @State var visible = false

    @State private var insectorPresented = false
    @State private var isMultiEditorMode: Bool = false

    let sidebarItems: [SidebarItem] = Storage.sharedInstance.sidebarItems

    @State var highlightedFunction: TextFunction? = nil
    @State var selectedFunction: TextFunction?
    @State var selectedFunctions: [TextFunction] = []
    @State var functionTrigger: Bool = false

    var body: some View {
        NavigationView {
            SidebarView(sidebarItems: sidebarItems, selectedFunction: $selectedFunction, highlightedFunction: $highlightedFunction)
                .searchable(text: $searchTerm, placement: .sidebar)

            VStack {
                GeometryReader { geometry in
                    if !isMultiEditorMode {
                        TextEditor(text: $editableText)
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
                        self.fireFunctionTrigger()
                    }
                }
                .onChange(of: selectedFunctions) { _, value in
                    if isMultiEditorMode {
                        self.nonEditableText = value.run(value: self.editableText)
                        self.fireFunctionTrigger()
                    }
                }
                .onChange(of: searchTerm) { _, value in
                    print("Search term: \(value)")
                }
                FooterView(text: $editableText, functionTrigger: $functionTrigger, isMultiEditorMode: $isMultiEditorMode)
                    .frame(height: 15)
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
    
    private func fireFunctionTrigger() {
        self.functionTrigger = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.functionTrigger = false
        }
    }

    #if os(macOS)
        private func quickOpenFilter(_ task: DSFQuickActionBar.SearchTask) {
            var results: [TextFunction] = []
            let searchTerm = task.searchTerm
            if searchTerm.count > 0 {
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
