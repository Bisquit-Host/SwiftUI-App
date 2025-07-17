import SwiftUI

enum NavMode: Int, Identifiable, CaseIterable, Codable {
    case stack,
         twoColumn,
         threeColumn
    
    var id: Int {
        rawValue
    }
    
    var name: LocalizedStringKey {
        switch self {
        case .stack: "Stack"
        case .twoColumn: "Two columns"
        case .threeColumn: "Three columns"
        }
    }
    
    var icon: String {
        switch self {
        case .stack: "list.bullet.rectangle.portrait"
        case .twoColumn: "sidebar.left"
        case .threeColumn: "rectangle.split.3x1"
        }
    }
}
