import Observation
import Network

@Observable
final class NetworkVM {
    private(set) var isNetworkSatisfied: Bool? = nil
    
    func defineStatus() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "ConnectionMonitor")
        
        monitor.pathUpdateHandler = { handler in
            switch handler.status {
            case .satisfied:
                self.isNetworkSatisfied = true
                
            default:
                self.isNetworkSatisfied = false
            }
        }
        
        monitor.start(queue: queue)
    }
}
