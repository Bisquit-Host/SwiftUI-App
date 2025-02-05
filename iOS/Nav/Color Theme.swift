import SwiftUI

enum ColorTheme: String, Identifiable, CaseIterable {
    case system, dark, light
    
    var id: String {
        self.rawValue
    }
    
    var scheme: ColorScheme? {
        switch self {
        case .system: .none
        case .dark:   .dark
        case .light:  .light
        }
    }
}
