import Foundation

// Primary associated types on the protocol
protocol NewWebSocketConnection<IncomingMessage, OutgoingMessage> {
    associatedtype IncomingMessage
    associatedtype OutgoingMessage
    
    func receive() -> AsyncThrowingStream<IncomingMessage, Error>
    func send(_ message: OutgoingMessage) async throws
}

// Example message types
struct IncomingMessage {
    let text: String
}

struct OutgoingMessage {
    let text: String
}

// One concrete connection implementation
struct URLSessionWebSocketConnection: NewWebSocketConnection {
    private let task: URLSessionWebSocketTask
    
    init(url: URL, session: URLSession = .shared) {
        self.task = session.webSocketTask(with: url)
        task.resume()
    }
    
    func receive() -> AsyncThrowingStream<IncomingMessage, Error> {
        AsyncThrowingStream { continuation in
            @Sendable
            func loop() {
                task.receive { result in
                    switch result {
                    case .failure(let error):
                        continuation.finish(throwing: error)
                        
                    case .success(let message):
                        switch message {
                        case .string(let string):
                            continuation.yield(IncomingMessage(text: string))
                            loop()
                            
                        default:
                            loop()
                        }
                    }
                }
            }
            
            loop()
        }
    }
    
    func send(_ message: OutgoingMessage) async throws {
        try await task.send(.string(message.text))
    }
}

@Observable
final class NewWebsocket {
    private var connection: URLSessionWebSocketConnection?
    
    func openAndConsumeWebSocketConnection() async {
        let url = URL(string: "wss://example.com/socket")!
        let connection = URLSessionWebSocketConnection(url: url)
        self.connection = connection
        
        do {
            for try await message in connection.receive() {
                switch message {
                case let msg:
                    print("Incoming:", msg.text)
                }
            }
        } catch {
            print("Error receiving messages:", error)
        }
        
        self.connection = nil
    }
    
    func sendMessage(_ message: OutgoingMessage) async {
        guard let connection else {
            print("Error sending message: no active connection")
            return
        }
        
        do {
            try await connection.send(message)
        } catch {
            print("Error sending message:", error)
        }
    }
}
