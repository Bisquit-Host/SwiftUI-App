// An enumeration of navigation experiences used to define the app architecture

import SwiftUI

enum Experience: Int, Identifiable, CaseIterable, Codable {
    case stack,
         twoColumn,
         threeColumn
    
    var id: Int {
        rawValue
    }
    
    /// The image name of the navigation experience.
    var imageName: String {
        switch self {
        case .stack: "list.bullet.rectangle.portrait"
        case .twoColumn: "sidebar.left"
        case .threeColumn: "rectangle.split.3x1"
        }
    }
    
    /// The localized name of the navigation experience.
    var localizedName: LocalizedStringKey {
        switch self {
        case .stack: "Stack"
        case .twoColumn: "Two columns"
        case .threeColumn: "Three columns"
        }
    }
    
    /// The localized descriptioon of the navigation experience.
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .stack:
            "Presents a stack of views over a root view."
            
        case .twoColumn:
            "Presents views in two columns: sidebar and detail."
            
        case .threeColumn:
            "Presents views in three columns: sidebar, content, and detail."
        }
    }
}
