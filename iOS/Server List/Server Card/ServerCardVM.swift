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
    private(set) var state: CalagopusServerState = .offline
    
    var serverURL: String {
        Endpoint.bisquitPter + "/server/" + id
    }
    
    var stateColor: Color {
        switch state {
        case .offline: .red
        case .running: .green
        default:       .yellow
        }
    }
    
    func fetchServerUsage() async {
        do {
            let usage = try await CalagopusNet.client().resources(server: id)
            updateUsage(usage)
        } catch {
            state = .offline
            SystemAlert.error(error)
        }
    }
    
    private func updateUsage(_ model: CalagopusResourceUsage) {
        cpuUsage = model.cpuAbsolute
        ramUsage = Double(model.memoryBytes)
        diskUsage = Double(model.diskBytes)
        
        withAnimation {
            state = model.state
            isLoading = false
        }
    }
}
