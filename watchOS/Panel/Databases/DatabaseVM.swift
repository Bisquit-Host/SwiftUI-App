import SwiftUI
import Calagopus

@Observable
final class DatabaseVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var databases: [CalagopusServerDatabase] = []
    
    func fetchDatabases() async {
        do {
            databases = try await CalagopusNet.client().databases(server: id).data
        } catch {
            SystemAlert.error(error)
        }
    }
}
