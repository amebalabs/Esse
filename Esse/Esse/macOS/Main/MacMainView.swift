import AppKit
import DSFQuickActionBar
import EsseCore
import NeonPlugin
import STTextViewUI
import SwiftUI

struct MacMainView: View {
    @Binding var document: EsseDocument
    @Environment(\.openWindow) private var openWindow

    @Environment(\.appearsActive) private var appearsActive

    @State private var nonEditableText: String = ""

    @State var searchTerm = ""
    @State var quickSearchIsVisible = false

    @AppStorage("dualPaneModeEnabled") var isMultiEditorMode: Bool = false
    @AppStorage("showLineNumbers") var showLineNumbers: Bool = true
    @AppStorage("highlightSelectedLine") var highlightSelectedLine: Bool = true

    @State var selectedFunction: TextFunction?
    @State var selectedFunctions: [TextFunction] = []
    @State var functionTrigger: Bool = false
    @State private var selection: NSRange?

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    TextView(text: $document.text,
                             selection: $selection,
                             showLineNumbers: $showLineNumbers,
                             highlightSelectedLine: $highlightSelectedLine,
                             plugins: [])
                        .frame(width: isMultiEditorMode ? geometry.size.width / 2 : .infinity)
                        .onChange(of: document.text) { _, value in
                            nonEditableText = selectedFunctions.run(value: String(value.characters))
                        }
                    if isMultiEditorMode {
                        TextEditor(text: $nonEditableText)
                            .multilineTextAlignment(.leading)
                            .frame(width: geometry.size.width / 2)
                            .font(.body)
                    }
                }
            }
            .onChange(of: selectedFunction) { _, value in
                guard let value else { return }
                if isMultiEditorMode {
                    selectedFunctions.append(value)
                } else {
                    document.text = AttributedString(value.run(String(document.text.characters)))
                    fireFunctionTrigger()
                }
                selectedFunction = nil
            }
            .onChange(of: selectedFunctions) { _, value in
                if isMultiEditorMode {
                    nonEditableText = value.run(value: String(document.text.characters))
                    fireFunctionTrigger()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .runFunctions), perform: { _ in
                guard appearsActive else { return }
                nonEditableText = selectedFunctions.run(value: String(document.text.characters))
                fireFunctionTrigger()
            })
            .onReceive(NotificationCenter.default.publisher(for: .showCommandPallete), perform: { _ in
                guard !quickSearchIsVisible, appearsActive else { return }
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
                itemsForSearchTerm: quickOpenFilter,
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
        functionTrigger = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            functionTrigger = false
        }
    }

    private func quickOpenFilter(_ task: DSFQuickActionBar.SearchTask) {
        let searchTerm = task.searchTerm
        var results: [TextFunction] = searchTerm.isEmpty ? Storage.sharedInstance.pAllFunctions : Storage.sharedInstance.filterFunctions(searchTerm: searchTerm)
        results = results.filter { !selectedFunctions.contains($0) }
        task.complete(with: results)
    }
}
