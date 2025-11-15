import Foundation

protocol NewWebSocketConnection<IncomingMessage, OutgoingMessage>: AnyObject {
    associatedtype IncomingMessage
    associatedtype OutgoingMessage
    
    func receive() -> AsyncThrowingStream<IncomingMessage, Error>
    func send(_ message: OutgoingMessage) async throws
    func close(with code: URLSessionWebSocketTask.CloseCode)
}

private enum WebSocketDefaults {
    static let origin = URL(string: "https://mgr.bisquit.host")!
    static let logStreamPayload = "{\"event\":\"send logs\",\"args\":[\"null\"]}"
}

private extension URLSessionWebSocketTask.Message {
    var textValue: String? {
        switch self {
        case .string(let string):
            string
            
        case .data(let data):
            String(data: data, encoding: .utf8)
            
        @unknown default:
            nil
        }
    }
}

final class URLSessionWebSocketConnection: NewWebSocketConnection {
    typealias IncomingMessage = String
    typealias OutgoingMessage = String
    
    private let task: URLSessionWebSocketTask
    private let stream: AsyncThrowingStream<String, Error>
    private let continuation: AsyncThrowingStream<String, Error>.Continuation
    private var receiveTask: Task<Void, Never>?
    private var isClosed = false
    
    init(
        url: URL,
        token: String,
        origin: URL = WebSocketDefaults.origin,
        session: URLSession = .shared
    ) {
        var continuation: AsyncThrowingStream<String, Error>.Continuation!
        
        self.stream = AsyncThrowingStream {
            continuation = $0
        }
        
        self.continuation = continuation
        
        var request = URLRequest(url: url)
        request.setValue(origin.absoluteString, forHTTPHeaderField: "Origin")
        
        task = session.webSocketTask(with: request)
        task.resume()
        
        startReceiveLoop()
        
        Task {
            await authenticate(using: token)
        }
    }
    
    private func startReceiveLoop() {
        let task = task
        let continuation = continuation
        
        receiveTask = Task {
            do {
                while !Task.isCancelled {
                    let message = try await task.receive()
                    
                    guard !Task.isCancelled else {
                        break
                    }
                    
                    if let text = message.textValue {
                        continuation.yield(text)
                    }
                }
                if !Task.isCancelled {
                    continuation.finish()
                }
            } catch {
                if Task.isCancelled {
                    continuation.finish()
                } else {
                    continuation.finish(throwing: error)
                }
            }
        }
        
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in
                self?.receiveTask?.cancel()
                self?.close(with: .goingAway)
            }
        }
    }
    
    private func authenticate(using token: String) async {
        do {
            try await task.send(.string("{\"event\":\"auth\",\"args\":[\"\(token)\"]}"))
            try await Task.sleep(nanoseconds: 500_000_000)
            try await task.send(.string(WebSocketDefaults.logStreamPayload))
        } catch {
            close(with: .abnormalClosure)
            continuation.finish(throwing: error)
        }
    }
    
    func receive() -> AsyncThrowingStream<String, Error> {
        stream
    }
    
    func send(_ message: String) async throws {
        try await task.send(.string(message))
    }
    
    func close(with code: URLSessionWebSocketTask.CloseCode = .goingAway) {
        guard !isClosed else {
            return
        }
        
        isClosed = true
        receiveTask?.cancel()
        task.cancel(with: code, reason: nil)
    }
    
    @MainActor
    deinit {
        close()
    }
}

final class NewWebsocket {
    private var connection: URLSessionWebSocketConnection?
    private var consumptionTask: Task<Void, Never>?
    
    func connect(
        to url: URL,
        token: String,
        origin: URL = WebSocketDefaults.origin,
        onTextMessage: @escaping @Sendable (String) async -> Void,
        onError: (@Sendable (Error) -> Void)? = nil
    ) {
        disconnect()
        
        let connection = URLSessionWebSocketConnection(
            url: url,
            token: token,
            origin: origin
        )
        
        self.connection = connection
        
        let stream = connection.receive()
        
        consumptionTask = Task {
            do {
                for try await message in stream {
                    try Task.checkCancellation()
                    await onTextMessage(message)
                }
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                
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
