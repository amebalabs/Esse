import SwiftUI

enum AppearanceOptions: String, CaseIterable {
    case System
    case Dark
    case Light

    func applyAppearance() {
        switch self {
        case .System:
            NSApp.appearance = nil
        case .Dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .Light:
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
}
