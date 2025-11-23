import Foundation

final class Websocket {
    private var connection: URLSessionWebsocketConnection?
    private var consumptionTask: Task<Void, Never>?
    
    func connect(
        to url: URL,
        token: String,
        origin: URL = WebsocketDefaults.origin,
        onTextMessage: @escaping @Sendable (String) async -> Void,
        onError: (@Sendable (Error) -> Void)? = nil
    ) {
        disconnect()
        
        let connection = URLSessionWebsocketConnection(url: url, token: token, origin: origin)
        self.connection = connection
        
        let stream = connection.receive()
        
        consumptionTask = Task {
            do {
                for try await message in stream {
                    try Task.checkCancellation()
                    await onTextMessage(message)
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                onError?(error)
            }
        }
    }
    
    func disconnect() {
        consumptionTask?.cancel()
        consumptionTask = nil
        connection?.close()
        connection = nil
    }
    
    func send(_ message: String) async throws {
        try await connection?.send(message)
    }
}
