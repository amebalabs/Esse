import DSFQuickActionBar
import AppKit
import EsseCore
import SwiftUI

struct MacMainView: View {
    @Binding var document: EsseDocument
    @Environment(\.openWindow) private var openWindow
    
    @Environment(\.appearsActive) private var appearsActive
    
    @State private var nonEditableText: String = ""

    @State var searchTerm = ""
    @State var quickSearchIsVisible = false

    @AppStorage("dualPaneModeEnabled") var isMultiEditorMode: Bool = false

    @State var selectedFunction: TextFunction?
    @State var selectedFunctions: [TextFunction] = []
    @State var functionTrigger: Bool = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                if !isMultiEditorMode {
                    TextEditor(text: $document.text)
                        .font(.body)
                } else {
                    HStack(spacing:0) {
                        TextEditor(text: $document.text)
                            .frame(width: geometry.size.width / 2)
                            .onChange(of: document.text) { _, value in
                                self.nonEditableText = selectedFunctions.run(value: value)
                            }
                            .font(.body)

                        TextEditor(text: $nonEditableText)
                            .multilineTextAlignment(.leading)
                            .frame(width: geometry.size.width / 2)
                            .font(.body)
                    }
                }
            }
            .onChange(of: selectedFunction) { _, value in
                guard let value else {return}
                if isMultiEditorMode {
                    selectedFunctions.append(value)
                } else {
                    document.text = value.run(document.text)
                    self.fireFunctionTrigger()
                }
                selectedFunction = nil
            }
            .onChange(of: selectedFunctions) { _, value in
                if isMultiEditorMode {
                    self.nonEditableText = value.run(value: document.text)
                    self.fireFunctionTrigger()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .runFunctions), perform: { _ in
                guard appearsActive else {return}
                self.nonEditableText = selectedFunctions.run(value: document.text)
                self.fireFunctionTrigger()
            })
            .onReceive(NotificationCenter.default.publisher(for: .showCommandPallete), perform: { _ in
                guard !quickSearchIsVisible, appearsActive else {return}
                quickSearchIsVisible = true
            })
            
            FooterView(text: $document.text,
                       transformedText: $nonEditableText,
                       functionTrigger: $functionTrigger,
                       isMultiEditorMode: $isMultiEditorMode,
                       selectedFunctions: $selectedFunctions)
                .frame(height: 15)
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
            }
            ToolbarItem {
                Button(action: {
                    openWindow(id: "library")
                }) {
                    Image(systemName: "book")
                }
            }
        }
    }
    
    private func fireFunctionTrigger() {
        self.functionTrigger = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.functionTrigger = false
        }
    }

    private func quickOpenFilter(_ task: DSFQuickActionBar.SearchTask) {
        let searchTerm = task.searchTerm
        var results: [TextFunction] = searchTerm.isEmpty ? Storage.sharedInstance.pAllFunctions : Storage.sharedInstance.filterFunctions(searchTerm: searchTerm)
        results = results.filter { !selectedFunctions.contains($0) }
        task.complete(with: results)
    }
    
}

//#Preview {
//    MacMainView()
//        .frame(width: 700, height: 500)
//}
//
//#Preview {
//    MacMainView(isMultiEditorMode: true)
//        .frame(width: 700, height: 500)
//}
