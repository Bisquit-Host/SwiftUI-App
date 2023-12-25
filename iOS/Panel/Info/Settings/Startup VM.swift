import PteroNet

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var startupVariables: [PNStartupVariableAttributes] = []
    
    func fetchStartupVariables() {
        listStartupVariablesAPI(id) { result in
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
        updateServerVariableAPI(id, variable: variable, newValue: newValue) { result in
            switch result {
            case .success:
                print("Changed")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func updateDockerImage(_ newDockerImage: String) {
        updateDockerImageAPI(id, newDockerImage: newDockerImage) { result in
            switch result {
            case .success:
                print("Updates")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
