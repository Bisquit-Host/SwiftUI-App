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
                guard
                    let firstKeyNumber = $0.key.split(separator: " ").last.flatMap({ Int($0) }),
                    let secondKeyNumber = $1.key.split(separator: " ").last.flatMap({ Int($0) })
                else {
                    return false
                }
                
                return firstKeyNumber > secondKeyNumber
            }
    }
    
    func fetchStartupVariables() {
        startupListAPI(id) { result in
            switch result {
            case .success(let model):
                if let model {
                    let meta = model.meta
                    
                    self.startupVariables = model.data.map(\.attributes)
                    self.startupCommand = meta.startupCommand
                    self.rawStartupCommand = meta.rawStartupCommand
                    
                    if let dockerImages = meta.dockerImages {
                        self.dockerImages = dockerImages
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func updateVariable(key: String, value: String, onFailure: @escaping () -> ()) {
        startupUpdateAPI(id, key: key, value: value) { result in
            switch result {
            case .success(let model):
                if let model {
                    if let index = self.startupVariables.firstIndex(where: {
                        $0.envVariable == model.attributes.envVariable
                    }) {
                        self.startupVariables[index] = model.attributes
                    }
                }
                
            case .failure(let error):
                SystemAlert.error(error)
                onFailure()
            }
        }
    }
    
    func updateDockerImage(_ newImage: String) {
        dockerUpdateAPI(id, newImage: newImage) { result in
            switch result {
            case .success:
                print("Updates")
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
}
