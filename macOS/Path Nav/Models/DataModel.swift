// An observable data model of servers and miscellaneous groupings

import SwiftUI
import PteroNet

@Observable
final class DataModel {
    private(set) var servers: [ServerAttributes] = []
    
    private var recipesById: [ServerAttributes.ID: ServerAttributes] = [:]
    
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
    
    func fetchServers(_ isAdmin: Bool) {
        serverListAPI(isAdmin) { result in
            switch result {
            case .success(let model):
                guard let model else {
                    return
                }
                
                let loadedServers = model.data.map(\.attributes)
                
                withAnimation {
                    self.servers = loadedServers
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    //    /// The servers for a given category, sorted by name
    //    func recipes(in category: Category?) -> [ServerAttributes] {
    //        servers.filter {
    //            $0.category == category
    //        }
    //    }
    
    /// Accesses the recipe associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(recipeId: ServerAttributes.ID) -> ServerAttributes? {
        recipesById[recipeId]
    }
}
