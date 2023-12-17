import PteroNet

final class PteroNet {
    static func powerSignal(_ id: String, signal: ServerSignal) {
        changePowerAPI(id, signal: signal) { result in
            switch result {
            case .success(let model):
                print(model)
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
    
    static func sendCommand(_ id: String, command: String) {
        sendCommandAPI(id, command: command) { result in
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
