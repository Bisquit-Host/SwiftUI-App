import SwiftUI
import Calagopus

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var databases: [DatabaseAttributes] = []
    
    func fetchDatabases() async {
        do {
            let databases: DatabaseListResponse? = try await dataListAPI(
                id,
                endpoint: .databases
            )
            
            if let databases = databases?.data.map(mapDatabaseAttributes) {
                self.databases = databases
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func mapDatabaseAttributes(_ database: DatabaseData) -> DatabaseAttributes {
        let relationshipPassword = database.attributes.relationships?.password?.attributes.password
        ?? database.relationships?.password?.attributes.password
        let attributes = database.attributes
        
        return DatabaseAttributes(
            id: attributes.id,
            name: attributes.name,
            username: attributes.username,
            password: relationshipPassword ?? attributes.password,
            host: attributes.host,
            connectionsFrom: attributes.connectionsFrom ?? "%",
            maxConnections: attributes.maxConnections,
            relationships: attributes.relationships ?? database.relationships
        )
    }
}
