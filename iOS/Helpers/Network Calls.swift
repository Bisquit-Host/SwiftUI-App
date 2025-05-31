import PteroNet

final class PteroNet {
    static func powerSignal(_ id: String, do signal: ServerSignal) async {
        do {
            try await serverPowerAPI(id, signal: signal)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static func sendCommand(_ id: String, command: String) async {
        do {
            try await serverCommandAPI(id, command: command)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static func reinstallServer(_ id: String, onSuccess: @escaping () -> Void = {}) {
        serverReinstallAPI(id) { result in
            switch result {
            case .success:
                print("Reinstalled")
                onSuccess()
                
            case .failure(let error):
                networkCallError(#function, error)
            }
        }
    }
}
