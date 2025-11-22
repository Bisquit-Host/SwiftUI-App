import Foundation

final class URLSessionWebsocketConnection: WebsocketConnection {
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
        origin: URL = WebsocketDefaults.origin,
        session: URLSession = .shared
    ) {
        var continuation: AsyncThrowingStream<String, Error>.Continuation!
        
        self.stream = AsyncThrowingStream {
            continuation = $0
        }
        
        self.continuation = continuation
        
        var req = URLRequest(url: url)
        req.setValue(origin.absoluteString, forHTTPHeaderField: "Origin")
        
        task = session.webSocketTask(with: req)
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
                    
                    guard !Task.isCancelled else { break }
                    
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
            try await task.send(.string(WebsocketDefaults.logStreamPayload))
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
        guard !isClosed else { return }
        
        isClosed = true
        receiveTask?.cancel()
        task.cancel(with: code, reason: nil)
    }
    
    @MainActor
    deinit {
        close()
    }
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
