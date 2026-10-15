import SwiftUI
import Calagopus

@Observable
final class DatabaseInstanceDetailsVM {
    private let serverID: String
    
    init(_ serverID: String, instance: CalagopusDatabaseInstance) {
        self.serverID = serverID
        self.instance = instance
    }
    
    private(set) var instance: CalagopusDatabaseInstance
    private(set) var resources: CalagopusDatabaseInstanceResources?
    private(set) var isSuspended = false
    var databases: [CalagopusDatabaseInstanceDatabase] = []
    var users: [CalagopusDatabaseInstanceUser] = []
    var databaseSizes: [String: Int64] = [:]
    private(set) var logs = ""
    private(set) var isLoadingLogs = false
    
    var alertRename = false
    var alertCreateDatabase = false
    var alertCreateUser = false
    var newName = ""
    var newDatabaseName = ""
    var newUsername = ""
    var newUserDatabaseID: String?
    
    var state: CalagopusServerState {
        resources?.state ?? .offline
    }
    
    var isOffline: Bool {
        state == .offline
    }
    
    func fetchAll() async {
        async let details: () = fetchDetails()
        async let databases: () = fetchDatabases()
        async let users: () = fetchUsers()
        
        _ = await (details, databases, users)
    }
    
    func fetchDetails() async {
        do {
            let response = try await CalagopusNet.client().databaseInstance(server: serverID, instance: instance.uuid)
            
            instance = response.instance
            resources = response.live?.utilization
            isSuspended = response.live?.suspended ?? false
        } catch {
            SystemAlert.error(error)
        }
    }
    
    /// Polls live resource usage while the caller's task is alive
    func pollResources() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(5))
            
            guard !Task.isCancelled else {
                return
            }
            
            if let resources = try? await CalagopusNet.client().databaseInstanceResources(server: serverID, instance: instance.uuid) {
                self.resources = resources
            }
        }
    }
    
    func power(_ action: CalagopusServerPowerAction) async {
        do {
            try await CalagopusNet.client().databaseInstancePower(server: serverID, instance: instance.uuid, action: action)
            try? await Task.sleep(for: .seconds(1))
            await fetchDetails()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func rename() async {
        do {
            try await CalagopusNet.client().updateDatabaseInstance(server: serverID, instance: instance.uuid, name: newName)
            newName = ""
            await fetchDetails()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func toggleLock() async {
        do {
            try await CalagopusNet.client().updateDatabaseInstance(server: serverID, instance: instance.uuid, locked: !instance.isLocked)
            await fetchDetails()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchLogs() async {
        isLoadingLogs = true
        defer {
            isLoadingLogs = false
        }
        
        do {
            logs = try await CalagopusNet.client().databaseInstanceLogs(server: serverID, instance: instance.uuid, lines: 200)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func export() async -> String? {
        do {
            return try await CalagopusNet.client().exportDatabaseInstance(server: serverID, instance: instance.uuid)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    // MARK: - Databases
    
    func fetchDatabases() async {
        guard instance.type != .redis else {
            return
        }
        
        do {
            databases = try await CalagopusNet.client().databaseInstanceDatabases(server: serverID, instance: instance.uuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func fetchSize(_ databaseID: String) async {
        guard let size = try? await CalagopusNet.client().databaseInstanceDatabaseSize(
            server: serverID,
            instance: instance.uuid,
            database: databaseID
        ) else {
            return
        }
        
        databaseSizes[databaseID] = size
    }
    
    func createDatabase() async {
        do {
            let database = try await CalagopusNet.client().createDatabaseInstanceDatabase(
                server: serverID,
                instance: instance.uuid,
                name: newDatabaseName
            )
            
            databases.append(database)
            newDatabaseName = ""
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteDatabase(_ databaseID: String) async {
        do {
            try await CalagopusNet.client().deleteDatabaseInstanceDatabase(server: serverID, instance: instance.uuid, database: databaseID)
            databases.removeAll { $0.id == databaseID }
            await fetchUsers()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func exportDatabase(_ databaseID: String) async -> String? {
        do {
            return try await CalagopusNet.client().exportDatabaseInstanceDatabase(server: serverID, instance: instance.uuid, database: databaseID)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    // MARK: - Users
    
    func fetchUsers() async {
        do {
            users = try await CalagopusNet.client().databaseInstanceUsers(server: serverID, instance: instance.uuid)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func createUser() async {
        do {
            let user = try await CalagopusNet.client().createDatabaseInstanceUser(
                server: serverID,
                instance: instance.uuid,
                username: newUsername,
                database: newUserDatabaseID
            )
            
            users.append(user)
            newUsername = ""
            newUserDatabaseID = nil
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func deleteUser(_ userID: String) async {
        do {
            try await CalagopusNet.client().deleteDatabaseInstanceUser(server: serverID, instance: instance.uuid, user: userID)
            users.removeAll { $0.id == userID }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func rotatePassword(_ userID: String) async {
        do {
            _ = try await CalagopusNet.client().rotateDatabaseInstanceUserPassword(server: serverID, instance: instance.uuid, user: userID)
            await fetchUsers()
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func user(_ userID: String) -> CalagopusDatabaseInstanceUser? {
        users.first { $0.id == userID }
    }
    
    func databaseName(_ databaseID: String?) -> String? {
        guard let databaseID else {
            return nil
        }
        
        return databases.first { $0.id == databaseID }?.name
    }
}
