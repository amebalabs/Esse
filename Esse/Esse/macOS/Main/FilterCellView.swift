import EsseCore
import SwiftUI

struct FilterCellView: View {
    let textFunction: TextFunction

    var body: some View {
        HStack {
            Image(systemName: "bolt")
                .font(.title)
            VStack(alignment: .leading) {
                HStack {
                    Text(textFunction.title).font(.title3)
                    Spacer()
                }
                HStack {
                    Text(textFunction.desc).font(.callout).foregroundColor(.gray).italic()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    FilterCellView(textFunction: Storage.sharedInstance.pAllFunctions.randomElement()!)
        .frame(width: 300).padding()
}
