import Observation
import Network

@Observable
final class NetworkVM {
    private(set) var isNetworkSatisfied: Bool? = nil
    
    func observeStatus() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "ConnectionMonitor")
        
        monitor.pathUpdateHandler = { handler in
            Task { @MainActor in
                self.isNetworkSatisfied = handler.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }
}
