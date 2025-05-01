// A data model for a recipe and its metadata, including its related servers

import SwiftUI

struct Recipe: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var category: Category
    var ingredients: [Ingredient]
    var imageName: String? = nil
}

extension Recipe {
    static var mock: Recipe {
        DataModel.shared.servers[0]
    }
}
