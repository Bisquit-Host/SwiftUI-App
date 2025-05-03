// An observable data model of servers and miscellaneous groupings

import SwiftUI
import PteroNet

@Observable
final class DataModel {
    private(set) var servers: [ServerAttributes] = []
    
    private var serversById: [ServerAttributes.ID: ServerAttributes] = [:]
    
    /// The shared singleton data model object
    static let shared: DataModel = {
        DataModel()
    }()
    
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
    
    /// Accesses the recipe associated with the given unique identifier
    /// if the identifier is tracked by the data model; otherwise, returns `nil`
    subscript(recipeId: ServerAttributes.ID) -> ServerAttributes? {
        serversById[recipeId]
    }
}
