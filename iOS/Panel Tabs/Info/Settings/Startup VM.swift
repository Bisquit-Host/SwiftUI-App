import PteroNet

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var startupVariables: [PNStartupVariableAttributes] = []
    
    func fetchStartupVariables() {
        startupListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.data {
                    self.startupVariables = model.map {
                        $0.attributes
                    }
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func changeVariable(variable: String, newValue: String) {
        startupUpdateAPI(id, variable: variable, newValue: newValue) { result in
            switch result {
            case .success:
                print("Changed")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func updateDockerImage(_ newImage: String) {
        dockerUpdateAPI(id, newImage: newImage) { result in
            switch result {
            case .success:
                print("Updates")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
