import PteroNet

final class PteroNet {
    static func powerSignal(
        _ id: String,
        do signal: ServerSignal
    ) async {
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
    
    static func reinstallServer(
        _ id: String,
        onSuccess: @escaping () -> Void = {}
    ) async {
        do {
            try await serverReinstallAPI(id)
            onSuccess()
        } catch {
            networkCallError(#function, error)
        }
    }
}
