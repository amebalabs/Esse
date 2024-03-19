import EsseCore
import SwiftUI

struct InspectorView: View {
    @Binding var textFunction: TextFunction?
    @State var inputText: String = """
    Here’s to the Crazy Ones!
    The misfits.
    The rebels.
    The troublemakers.
    The round pegs in the square holes.
    The ones who see things differently.

    Some numbers: 1233
    """
    @State var outputText: String = ""
    var body: some View {
        if textFunction == nil {
            Text("Select a Function")
                .font(.title2)
                .foregroundStyle(.secondary)
        } else {
            Form {
                Section(content: {
                    VStack(alignment: .leading) {    
                        Text("")
                        Text(textFunction!.desc)
                    }
                }, header: {
                    Text(textFunction!.title)
                        .font(.title)
                        .multilineTextAlignment(.leading)
                })
                
                Divider()
                
                Section(content: {
                    TextEditor(text: $inputText)
                        .scrollIndicators(.never)
                        .frame(height: 200)
                        .onChange(of: inputText) { value, _ in
                            self.outputText = textFunction!.run(value)
                        }
                }, header: {
                    Text("Input")
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                })
                Section(content: {
                    TextEditor(text: $outputText)
                        .scrollIndicators(.never)
                        .frame(height: 200)
                }, header: {
                    Text("Output")
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                })
                Spacer()
            }
            .formStyle(.automatic)
            .onAppear {
                outputText = textFunction?.run(inputText) ?? ""
            }
            .onChange(of: $textFunction.wrappedValue) {
                outputText = textFunction?.run(inputText) ?? ""
            }
        }
    }
}

#Preview {
    InspectorView(textFunction: .constant(Storage.sharedInstance.pAllFunctions.randomElement()!))
        .frame(width: 300, height: 800)
}
