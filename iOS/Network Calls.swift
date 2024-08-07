import PteroNet

final class PteroNet {
    static func powerSignal(_ id: String, signal: ServerSignal) {
        serverPowerAPI(id, signal: signal) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    static func sendCommand(_ id: String, command: String) {
        serverCommandAPI(id, command: command) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    static func reinstallServer(_ id: String) {
        serverReinstallAPI(id) { result in
            switch result {
            case .success:
                print("Reinstalled")
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
