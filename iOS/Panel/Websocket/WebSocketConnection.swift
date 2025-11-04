import Foundation

protocol WebSocketConnection: AnyObject {
    var delegate: WebSocketConnectionDelegate? {
        get set
    }
    
    func connect()
    func disconnect()
    func send(_ text: String)
    func send(_ data: Data)
}
