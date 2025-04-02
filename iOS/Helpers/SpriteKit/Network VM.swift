import ScrechKit
import Network

@Observable
final class NetworkVM {
    private(set) var isNetworkSatisfied: Bool? = nil
    
    init() {
        defineNetworkStatus()
    }
    
    func defineNetworkStatus() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "ConnectionMonitor")
        
        monitor.pathUpdateHandler = { handler in
            main { [self] in
                switch handler.status {
                case .satisfied:
                    isNetworkSatisfied = true
                    
                default:
                    isNetworkSatisfied = false
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
