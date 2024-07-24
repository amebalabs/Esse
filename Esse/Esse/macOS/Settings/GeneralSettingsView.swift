import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("appearance") private var appearance: AppearanceOptions = .System
    var body: some View {
        Form {
            EnumPickerView(selected: $appearance, title: "Appearance")
            LaunchAtLogin.Toggle()
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
