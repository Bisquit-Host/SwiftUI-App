import SwiftUI
import PteroNet

@Observable
final class ServerCardVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    private(set) var ramUsage = 0.0
    private(set) var cpuUsage = 0.0
    private(set) var diskUsage = 0.0
    private(set) var isLoading = true
    private(set) var stateColor: Color = .red
    
    func fetchServerUsage() async {
        do {
            let usage = try await serverUsageAPI(id)
            updateUsage(usage)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    private func updateUsage(_ model: ResourceUsageAttributes) {
        let usage = model.usage
        
        cpuUsage = usage.cpu
        ramUsage = usage.memory
        diskUsage = usage.disk
        
        withAnimation {
            switch model.state {
            case .offline:        stateColor = .red
            case .running:        stateColor = .green
            case .suspended:      stateColor = .gray
            default: stateColor = .yellow
            }
            
            isLoading = false
        }
    }
}
