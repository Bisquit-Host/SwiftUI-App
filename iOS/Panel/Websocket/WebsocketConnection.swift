import Foundation

protocol WebsocketConnection<IncomingMessage, OutgoingMessage>: AnyObject {
    associatedtype IncomingMessage
    associatedtype OutgoingMessage
    
    func receive() -> AsyncThrowingStream<IncomingMessage, Error>
    func send(_ message: OutgoingMessage) async throws
    func close(with code: URLSessionWebSocketTask.CloseCode)
}
