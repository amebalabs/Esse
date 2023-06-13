import EsseCore
import SwiftUI

struct FooterView: View {
    @Binding var footerItems: [TextFunction]

    var body: some View {
        HStack {
            Image(systemName: "function")
                .font(.title)
                .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(footerItems.indices, id: \.self) { index in
                        HStack {
                            Text(footerItems[index].title)
                            Button(action: {
                                footerItems.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(6)
                        .background(Color.accentColor.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .onMove(perform: move)
                }
                .padding()
            }

            if footerItems.count > 1 {
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Text("Save")
                })
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .frame(height: 30)
    }

    private func move(from source: IndexSet, to destination: Int) {
        footerItems.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    FooterView(footerItems: .constant([Storage.sharedInstance.pAllFunctions.randomElement()!]))
        .frame(height: 40)
}
