import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("appearance") private var appearance: AppearanceOptions = .System
    @AppStorage("showLineNumbers") var showLineNumbers: Bool = true
    @AppStorage("highlightSelectedLine") var highlightSelectedLine: Bool = true
    
    var body: some View {
        Form {
            LaunchAtLogin.Toggle()
            Toggle(isOn: $showLineNumbers, label: {
                Text("Show Line Numbers")
            })
            Toggle(isOn: $highlightSelectedLine, label: {
                Text("Highlight Selected Line")
            })
            Spacer()
            EnumPickerView(selected: $appearance, title: "Appearance")
        }
        .onChange(of: appearance) { _, value in
            value.applyAppearance()
        }
        .padding(20)
        .frame(width: 350, height: 100)
    }
}

#Preview {
    GeneralSettingsView()
}
