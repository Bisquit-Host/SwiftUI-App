import ScrechKit
import PteroNet

@Observable
final class ServerSettingsVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var alertRename = false
    var serverName = ""
    var serverDescription = ""
    
    func serverRename() {
        serverRenameAPI(
            id,
            name: serverName,
            description: serverDescription
        ) { result in
            switch result {
            case .success:
                print("Renamed")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }    
}
