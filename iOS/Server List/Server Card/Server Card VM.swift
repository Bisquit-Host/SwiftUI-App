import ScrechKit
import PteroNet

@Observable
final class ServerCardVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var ram_usage = 0.0
    var cpu_usage = 0.0
    var disk_usage = 0.0
    var stateColor: Color = .yellow
    var isLoadingData = true
    
    func fetchServerUsage() {
        serverUsageAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.updateUsage(model)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    func updateUsage(_ model: ResourceUsageAttributes) {
        let usage = model.usage
        
        cpu_usage = usage.cpu
        ram_usage = usage.memory
        disk_usage = usage.disk
        
        withAnimation {
            switch model.state {
            case "offline":
                stateColor = .red
                
            case "running":
                stateColor = .green
                
            default:
                stateColor = .yellow
            }
            
            isLoadingData = false
        }
    }
}
