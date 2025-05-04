import SwiftUI

enum NavMode: Int, Identifiable, CaseIterable, Codable {
    case stack,
         twoColumn,
         threeColumn
    
    var id: Int {
        rawValue
    }
    
    var imageName: String {
        switch self {
        case .stack: "list.bullet.rectangle.portrait"
        case .twoColumn: "sidebar.left"
        case .threeColumn: "rectangle.split.3x1"
        }
    }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .stack: "Stack"
        case .twoColumn: "Two columns"
        case .threeColumn: "Three columns"
        }
    }
    
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .stack:
            "Presents a stack of views over a root view"
            
        case .twoColumn:
            "Presents views in two columns: sidebar and detail"
            
        case .threeColumn:
            "Presents views in three columns: sidebar, content, and detail"
        }
    }
}
