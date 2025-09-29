import Foundation

protocol WebSocketConnectionDelegate: AnyObject {
    func onStateChanged(connection: WebSocketConnection, state: WebSocketConnectionState)
    func onConnecting(connection: WebSocketConnection)
    func onDisconnecting(connection: WebSocketConnection)
    func onError(connection: WebSocketConnection, error: Error)
    func onTextMessage(connection: WebSocketConnection, message: String)
    func onDataMessage(connection: WebSocketConnection, message: Data)
}
