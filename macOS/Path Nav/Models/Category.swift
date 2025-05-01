// An enumeration of recipe groupings used to display sidebar items

import SwiftUI

enum Category: Int, CaseIterable, Identifiable, Codable {
    case dessert,
         pancake,
         salad,
         sandwich
    
    var id: Int {
        rawValue
    }
    
    /// The localized name of the recipe category.
    var localizedName: LocalizedStringKey {
        switch self {
        case .dessert: "Dessert"
        case .pancake: "Pancake"
        case .salad: "Salad"
        case .sandwich: "Sandwich"
        }
    }
}
