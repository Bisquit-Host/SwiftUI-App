import SwiftUI
import OSLog
import Calagopus

@Observable
final class DatabaseInstanceVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var instances: [CalagopusDatabaseInstance] = []
    var templates: [CalagopusDatabaseInstanceTemplate] = []
    private(set) var isLoadingInstances = false
    private(set) var hasFinishedLoadingInstances = false
    var showCreateSheet = false
    var detailsInstance: CalagopusDatabaseInstance?
    
    /// Managed databases are relevant when the server already has instances or can deploy new ones
    var isAvailable: Bool {
        !instances.isEmpty || !templates.isEmpty
    }
    
    var serverID: String {
        id
    }
    
    func fetchInstances() async {
        guard !isLoadingInstances else {
            return
        }
        
        isLoadingInstances = true
        defer {
            isLoadingInstances = false
            hasFinishedLoadingInstances = true
        }
        
        async let instancesTask: () = loadInstances()
        async let templatesTask: () = loadTemplates()
        
        _ = await (instancesTask, templatesTask)
    }
    
    func createInstance(template: CalagopusDatabaseInstanceTemplate, name: String, image: String?) async -> Bool {
        do {
            let instance = try await CalagopusNet.client().createDatabaseInstance(
                server: id,
                template: template.uuid,
                name: name,
                image: image
            )
            
            instances.append(instance)
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func deleteInstance(_ instanceID: String) async -> Bool {
        do {
            try await CalagopusNet.client().deleteDatabaseInstance(server: id, instance: instanceID)
            instances.removeAll { $0.id == instanceID }
            return true
        } catch {
            SystemAlert.error(error)
            return false
        }
    }
    
    func power(_ instanceID: String, action: CalagopusServerPowerAction) async {
        do {
            try await CalagopusNet.client().databaseInstancePower(server: id, instance: instanceID, action: action)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func replace(_ instance: CalagopusDatabaseInstance) {
        guard let index = instances.firstIndex(where: { $0.id == instance.id }) else {
            return
        }
        
        instances[index] = instance
    }
    
    private func loadInstances() async {
        do {
            instances = try await CalagopusNet.client().databaseInstances(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func loadTemplates() async {
        do {
            templates = try await CalagopusNet.client().databaseInstanceTemplates(server: id)
        } catch {
            // Templates are optional, servers without database agents respond with an error
            Logger().info("Database instance templates unavailable: \(error.localizedDescription)")
            templates = []
        }
    }
}
