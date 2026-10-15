import SwiftUI
import Calagopus

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var instances: [CalagopusDatabaseInstance] = []
    
    func fetchInstances() async {
        do {
            instances = try await CalagopusNet.client().databaseInstances(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func users(_ instanceID: String) async -> [CalagopusDatabaseInstanceUser] {
        do {
            return try await CalagopusNet.client().databaseInstanceUsers(server: id, instance: instanceID)
        } catch {
            SystemAlert.error(error)
            return []
        }
    }
}
