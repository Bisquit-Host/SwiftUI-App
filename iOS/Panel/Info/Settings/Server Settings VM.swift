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
    var startupVariables: [PNStartupVariable] = []
    
    func serverRename() {
        renameServerAPI(
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
    
    func fetchStartupVariables() {
        listStartupVariablesAPI(id) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.startupVariables = model.data
                }
                
            case .failure(let error):
                print("fetchStartupVariables \(error.localizedDescription)")
            }
        }
    }
}
