import SwiftUI
import EsseCore

struct FooterView: View {
    @Binding var text: String
    @Binding var transformedText:String
    @Binding var functionTrigger: Bool
    @Binding var isMultiEditorMode: Bool
    @Binding var selectedFunctions: [TextFunction]
    @State var floatingEnabled: Bool = false
    @State var isHovering: Bool = false
    @State var activeTootltip: String = ""
    
    @State var showSheet: Bool = false
    
    var isMainWindowFloating: Bool {
        NSApp.mainWindow?.level == .floating
    }
    var statsText: String {
        "\(text.lines().count) lines • \(text.words().count) words • \(text.count) characters"
    }
    
    var body: some View {
        HStack {
            Text(isHovering ? activeTootltip:statsText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.leading)
            
            Spacer()
            
            if isMultiEditorMode {
                Button(action: {
                    self.showSheet = true
                }) {
                    Image(systemName: "function")
                        .font(.system(size: 19))
                }
                .buttonStyle(.plain)
                .opacity(functionTrigger ? 1:0.5)
                .foregroundColor(functionTrigger ? .blue : .primary)
                .animation(.bouncy, value: functionTrigger)
                .onHover { hovering in
                    activeTootltip = "Show Selected Functions"
                    isHovering = hovering
                }
                .popover(isPresented: $showSheet, content: {
                    SelectedFunctionsView(functions: $selectedFunctions, isPresented: self.$showSheet)
                })
                Divider()
            }
            
            Button(action: {
                NSApp.mainWindow?.level = (isMainWindowFloating ? .normal : .floating)
                floatingEnabled.toggle()
            }) {
                Image(systemName: (floatingEnabled ? "pin.circle.fill":"pin.circle"))
                    .font(.system(size: 19))
            }
            .buttonStyle(.plain)
            .opacity(0.5)
            .onHover { hovering in
                activeTootltip = floatingEnabled ? "Behave like a Normal Window" : "Float on Top of All Other Windows"
                isHovering = hovering
            }
            

            ShareLink(item: isMultiEditorMode ? transformedText:text)  {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 19))
            }
            .buttonStyle(.plain)
            .opacity(0.5)
            .padding(.trailing, 8)
            .onHover { hovering in
                activeTootltip = "Share All Text"
                isHovering = hovering
            }
        }
    }
}


struct SelectedFunctionsView: View {
    @Binding var functions: [TextFunction]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if functions.isEmpty {
                Text("No Fucntions Selected")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(Array(functions.enumerated()), id: \.element) { index, item in
                        HStack {
                            Text("\(index + 1).")
                            Text(item.title)
                            Spacer()
                            Button(action: {
                               delete(at: index)
                            }) {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(.plain)
                            .opacity(0.5)
                        }
                    }
                    .onMove(perform: move)
                }
                Spacer()
                HStack {
                    Button(action: {
                        functions.removeAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isPresented = false
                        }
                    }) {
                        Label(
                            title: { Text("Remove All") },
                            icon: { Image(systemName: "trash") }
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .opacity(0.5)
                }
            }
        }
        .padding(.bottom)
        .frame(width: 300, height: 300)
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        functions.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(at index: Int) {
        functions.remove(at: index)
    }
}

struct ReorderableList: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                Spacer()
                Button("Delete") {
                    delete(item: item)
                }
            }
            .onMove(perform: move)
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func delete(item: String) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
}


#Preview {
    FooterView(text: .constant("Hello, World! \n Oh, Yeah!"), transformedText: .constant("Hello, World! \n Oh, Yeah!"), functionTrigger: .constant(true), isMultiEditorMode: .constant(true), selectedFunctions: .constant([Storage.sharedInstance.pAllFunctions.randomElement()!]))
        .frame(height: 15)
        .padding()
}
