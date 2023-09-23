import SwiftUI

struct YourSheetView: View {
    @Binding var isPresented: Bool
    var detachAction: () -> Void
    
    var body: some View {
        VStack {
            ReorderableList()
            
            Button("Detach") {
                self.isPresented = false // Close the sheet
                detachAction() // Detach to new window
            }
        }.frame(width: 300, height: 400) 
    }
}

struct ReorderableList: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    
    var body: some View {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onMove(perform: move)
            }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

struct FooterView: View {
    @Binding var text: String
    @Binding var functionTrigger: Bool
    @Binding var isMultiEditorMode: Bool
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
                    YourSheetView(isPresented: self.$showSheet, detachAction: self.detachSheet)
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
            

            ShareLink(item: text)  {
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
    
    func detachSheet() {
        let newWindow = NSWindow(
            contentRect: CGRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        let hostingView = NSHostingView(rootView: YourSheetView(
            isPresented: .constant(false), // As it's detached, no need to control the presentation
            detachAction: {}
        ))
        
        newWindow.contentView = hostingView
        newWindow.makeKeyAndOrderFront(nil)
    }
}




#Preview {
    FooterView(text: .constant("Hello, World! \n Oh, Yeah!"), functionTrigger: .constant(true), isMultiEditorMode: .constant(true))
        .frame(height: 15)
        .padding()
}
