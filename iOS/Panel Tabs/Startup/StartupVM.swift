import Foundation
import Calagopus

@Observable
final class StartupVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var startupCommand = ""
    private(set) var rawStartupCommand = ""
    private(set) var startupVariables: [StartupVariable] = []
    private(set) var dockerImages: [String: String] = [:]
    
    var sortedDockerImages: [(key: String, value: String)] {
        Array(dockerImages)
            .sorted {
                guard
                    let firstKeyNumber = $0.key.split(separator: " ").last.flatMap({ Double($0) }),
                    let secondKeyNumber = $1.key.split(separator: " ").last.flatMap({ Double($0) })
                else {
                    return false
                }
                
                return firstKeyNumber > secondKeyNumber
            }
    }
    
    func fetchStartupVariables() async {
        do {
            let model = try await startupListAPI(id)
            let meta = model.meta
            
            startupVariables = model.data.map(\.attributes)
            startupCommand = meta.startupCommand
            rawStartupCommand = meta.rawStartupCommand
            
            if let dockerImages = meta.dockerImages {
                self.dockerImages = dockerImages
            }
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func updateVariable(
        key: String,
        value: String,
        onSuccess: @escaping (StartupVariable) -> () = { _ in },
        onFailure: @escaping () -> ()
    ) async {
        do {
            let model = try await startupUpdateAPI(id, key: key, value: value)
            
            if let index = startupVariables.firstIndex(where: {
                $0.envVariable == model.attributes.envVariable
            }) {
                startupVariables[index] = model.attributes
            }
            
            onSuccess(model.attributes)
        } catch {
            SystemAlert.error(error)
            onFailure()
        }
    }
    
    func updateDockerImage(_ newImage: String) async {
        do {
            try await dockerUpdateAPI(id, newImage: newImage)
        } catch {
            SystemAlert.error(error)
        }
    }
}
