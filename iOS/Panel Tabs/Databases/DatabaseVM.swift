import SwiftUI
import Calagopus

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var databases: [DatabaseAttributes] = []
    var newDatabaseName = ""
    var alertCreate = false
    
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
    
    func rotatePassword(_ dbId: String) async {
        do {
            let model = try await databaseRotatePasswordAPI(id, dbId: dbId)
            
            if let index = databases.firstIndex(where: { $0.id == model.id }) {
                databases[index] = model
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createDatabase() async {
        do {
            let db = try await databaseCreateAPI(id, name: newDatabaseName)
            
            databases.append(db)
            newDatabaseName = ""
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteDatabases(_ offsets: IndexSet) async {
        for index in offsets {
            let id = databases[index].id
            await deleteDatabase(id)
        }
    }
    
    func deleteDatabase(_ uuid: String) async {
        do {
            try await dataDeleteAPI(id, itemId: uuid, endpoint: .databases)
            await fetchDatabases()
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
