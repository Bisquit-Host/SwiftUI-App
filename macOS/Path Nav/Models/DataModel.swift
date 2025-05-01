// An observable data model of servers and miscellaneous groupings

import SwiftUI

@Observable
final class DataModel {
    private(set) var servers: [Recipe] = []
    
    private var recipesById: [Recipe.ID: Recipe] = [:]
    
    /// The shared singleton data model object
    static let shared: DataModel = {
        DataModel()
    }()
    
    private static var dataURL: URL {
        get throws {
            let bundle = Bundle.main
            
            guard
                let path = bundle.path(forResource: "Recipes", ofType: "json")
            else {
                throw CocoaError(.fileReadNoSuchFile)
            }
            
            return URL(fileURLWithPath: path)
        }
    }
    
    /// The servers for a given category, sorted by name
    func recipes(in category: Category?) -> [Recipe] {
        servers.filter {
            $0.category == category
        }
    }
    
    /// Accesses the recipe associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(recipeId: Recipe.ID) -> Recipe? {
        recipesById[recipeId]
    }
}
