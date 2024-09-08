import PteroNet

final class MyWebSocketDelegate: WebSocketConnectionDelegate {
    private let onTextMessage: (String) -> Void
    
    init(onTextMessage: @escaping (String) -> Void) {
        self.onTextMessage = onTextMessage
    }
    
    func onStateChanged(connection: WebSocketConnection, state: WebSocketConnectionState) {
        let status = "Status: \(state)"
        
        Logger.webSocket.log("\(status)")
    }
    
    func onConnecting(connection: WebSocketConnection) {
        Logger.webSocket.log("Connecting...")
    }
    
    func onDisconnecting(connection: WebSocketConnection) {
        Logger.webSocket.log("Disconnecting...")
    }
    
    func onError(connection: WebSocketConnection, error: Error) {
        Logger.webSocket.error("\(error.localizedDescription)")
        
        SystemAlert.error(error)
    }
    
    func onTextMessage(connection: WebSocketConnection, message: String) {
        //        Logger.webSocket.log("Received message: \(message)")
        
        onTextMessage(message)
    }
    
    func onDataMessage(connection: WebSocketConnection, message: Data) {
        Logger.webSocket.log("Received data: \(message)")
    }
}
