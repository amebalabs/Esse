#if os(macOS)
import DSFQuickActionBar
import STTextViewUI
import STTextView
#endif
import EsseCore
import SwiftUI

struct MacMainView: View {
    @State private var editableText: String = ""
    @State private var nonEditableText: String = ""

    @State var searchTerm = ""
    @State var quickSearchIsVisible = false

    @State var isMultiEditorMode: Bool = false

    @State var selectedFunction: TextFunction?
    @State var selectedFunctions: [TextFunction] = []
    @State var functionTrigger: Bool = false

    var body: some View {
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
            FooterView(text: $editableText,
                       transformedText: $nonEditableText,
                       functionTrigger: $functionTrigger,
                       isMultiEditorMode: $isMultiEditorMode,
                       selectedFunctions: $selectedFunctions)
                .frame(height: 15)
            #if os(macOS)
                QuickActionBar<TextFunction, FilterCellView>(
                    location: .window,
                    visible: $quickSearchIsVisible,
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
            ToolbarItem {
                Toggle(isOn: $isMultiEditorMode) {
                    Label("Editor Mode", systemImage: "rectangle.split.2x1")
                }
                .toggleStyle(.automatic)
            }
            ToolbarItem {
                Button(action: {
                    quickSearchIsVisible = true
                }) {
                    Image(systemName: "command")
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
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

#Preview {
    MacMainView(isMultiEditorMode: true)
        .frame(width: 700, height: 500)
}
