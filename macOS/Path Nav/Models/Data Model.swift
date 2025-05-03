// An observable data model of servers and miscellaneous groupings

import SwiftUI
import PteroNet

@Observable
final class DataModel {
    private(set) var servers: [ServerAttributes] = []
    
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
}
