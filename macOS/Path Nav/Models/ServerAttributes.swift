//// A data model for a recipe and its metadata, including its related servers
//
//import SwiftUI
//
//struct ServerAttributes: Codable, Hashable, Identifiable {
//    let id: UUID
//    var name: String
//    var category: Category
//    var ingredients: [Ingredient]
//    var imageName: String? = nil
//}
//
//extension ServerAttributes {
//    static var mock: ServerAttributes {
//        DataModel.shared.servers[0]
//    }
//}
