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
    var username = ""
    
    func serverRename() {
        serverRenameAPI(id, name: serverName, description: serverDescription) { result in
            switch result {
            case .success:
                print("Sucsess")
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func accountDetails() {
        accountDetailsAPI { [self] result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    username = model.username
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
