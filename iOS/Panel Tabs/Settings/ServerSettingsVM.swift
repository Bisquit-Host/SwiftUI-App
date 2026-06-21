import SwiftUI
import Calagopus

@Observable
final class ServerSettingsVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var alertRename = false
    var serverName = ""
    var serverDescription = ""
    var username = ""
    
    func serverRename() async {
        do {
            try await serverRenameAPI(id, name: serverName, description: serverDescription)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func accountDetails() async {
        do {
            username = try await accountDetailsAPI().username
        } catch {
            SystemAlert.error(error)
        }
    }
}
