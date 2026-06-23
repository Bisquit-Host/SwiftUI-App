import SwiftUI
import Calagopus

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var databases: [CalagopusServerDatabase] = []
    var newDatabaseName = ""
    var alertCreate = false
    
    func fetchDatabases() async {
        do {
            databases = try await CalagopusNet.client().databases(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func rotatePassword(_ dbId: String) async {
        do {
            let password = try await CalagopusNet.client().rotateDatabasePassword(server: id, database: dbId)
            
            if let index = databases.firstIndex(where: { $0.id == dbId }) {
                let database = databases[index]
                databases[index] = CalagopusServerDatabase(
                    uuid: database.uuid,
                    type: database.type,
                    host: database.host,
                    port: database.port,
                    name: database.name,
                    isLocked: database.isLocked,
                    username: database.username,
                    password: password ?? database.password,
                    created: database.created
                )
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createDatabase() async {
        do {
            let db = try await CalagopusNet.client().createDatabase(server: id, name: newDatabaseName)
            
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
            try await CalagopusNet.client().deleteDatabase(server: id, database: uuid)
            await fetchDatabases()
        } catch {
            SystemAlert.error(error)
        }
    }
}
