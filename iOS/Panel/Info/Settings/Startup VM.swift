import Foundation
import PteroNet

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
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
