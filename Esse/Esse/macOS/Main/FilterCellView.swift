import EsseCore
import SwiftUI

struct FilterCellView: View {
    let textFunction: TextFunction

    var body: some View {
        HStack {
//            Image(systemName: "bolt")
//                .font(.title)
            VStack(alignment: .leading) {
                HStack {
                    Text(textFunction.title)
                        .font(.title2)
                        .fontWeight(.medium)
                    Spacer()
                }
                HStack {
                    Text(textFunction.desc)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .italic()
                    Spacer()
                }
            }
        }.environment(\.colorScheme, .dark)
    }
}

#Preview {
    FilterCellView(textFunction: Storage.sharedInstance.pAllFunctions.randomElement()!)
        .frame(width: 300).padding()
}
