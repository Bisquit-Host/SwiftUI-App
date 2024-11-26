import ScrechKit
import PteroNet

@Observable
final class ServerCardVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var ramUsage = 0.0
    var cpuUsage = 0.0
    var diskUsage = 0.0
    var stateColor: Color = .red
    var isLoading = true
    
    func fetchServerUsage() {
        serverUsageAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.updateUsage(model)
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func updateUsage(_ model: ResourceUsageAttributes) {
        let usage = model.usage
        
        cpuUsage = usage.cpu
        ramUsage = usage.memory
        diskUsage = usage.disk
        
        withAnimation {
            switch model.state {
            case "offline":
                stateColor = .red
                
            case "running":
                stateColor = .green
                
            default:
                stateColor = .yellow
            }
            
            isLoading = false
        }
    }
}
