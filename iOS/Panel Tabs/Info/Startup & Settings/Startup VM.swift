import PteroNet

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var startupVariables: [StartupVariable] = []
    var dockerImages: [String: String] = [:]
    var startupCommand = ""
    var rawStartupCommand = ""
    
    var sortedDockerImages: [(key: String, value: String)] {
        Array(dockerImages)
            .sorted {
                Int($0.key.split(separator: " ").last!)! > Int($1.key.split(separator: " ").last!)!
            }
    }
    
    func fetchStartupVariables() {
        startupListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model {
                    self.startupVariables = model.data.map {
                        $0.attributes
                    }
                    
                    self.startupCommand = model.meta.startupCommand
                    self.rawStartupCommand = model.meta.rawStartupCommand
                    
                    self.dockerImages = model.meta.dockerImages
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
        dockerUpdateAPI(id, newImage: newImage, printResponse: true) { result in
            switch result {
            case .success:
                print("Updates")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
