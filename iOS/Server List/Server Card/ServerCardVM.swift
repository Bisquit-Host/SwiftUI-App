import SwiftUI
import Calagopus

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
    private(set) var state: ResourceUsageState = .offline
    
    var serverURL: String {
        Endpoint.bisquitPter + "/server/" + id
    }
    
    var stateColor: Color {
        switch state {
        case .offline:   .red
        case .running:   .green
        case .suspended: .gray
        default:         .yellow
        }
    }
    
    func fetchServerUsage() async {
        do {
            let usage = try await serverUsageAPI(id)
            updateUsage(usage)
        } catch {
            state = .suspended
            SystemAlert.error(error)
        }
    }
    
    private func updateUsage(_ model: ResourceUsageAttributes) {
        let usage = model.usage
        
        cpuUsage = usage.cpu
        ramUsage = usage.memory
        diskUsage = usage.disk
        
        withAnimation {
            state = model.state
            isLoading = false
        }
    }
}
